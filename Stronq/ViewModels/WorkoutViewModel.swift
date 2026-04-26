import SwiftUI
import SwiftData
import UserNotifications

@Observable
@MainActor
final class WorkoutViewModel {
    var activeSession: WorkoutSession?
    var isWorkoutActive = false
    var restTimerRemaining: Int = 0
    var isRestTimerRunning = false
    var elapsedTime: TimeInterval = 0

    var groupMode: GroupMode = .fixed(5)
    var plannedExercises: [PlannedWorkoutExercise] = []
    var dayName: String = "Heavy"
    var weekNumber: Int = 1
    var doneExercises: Set<String> = []
    private var groupsPerExercise: [String: Int] = [:]
    private var definition: ProgramDefinition?

    private var restTimerTask: Task<Void, Never>?
    private var elapsedTimerTask: Task<Void, Never>?
    private var setRestDuration: Int = 60
    private var seriesRestDuration: Int = 180
    private let timerManager = TimerManager()

    // MARK: - Setup

    func prepareWorkout(program: Program, modelContext: ModelContext? = nil) {
        plannedExercises = []
        guard let def = program.definition else { return }
        definition = def

        let calculatedWeek = WorkoutEngine.currentWeek(
            startDate: program.startDate,
            currentDate: .now,
            definition: def
        )
        if calculatedWeek > program.currentWeek {
            program.currentWeek = calculatedWeek
        }

        var freshSessions: [WorkoutSession]?
        if let modelContext {
            let programID = program.id
            let descriptor = FetchDescriptor<WorkoutSession>(
                predicate: #Predicate { $0.program?.id == programID }
            )
            freshSessions = try? modelContext.fetch(descriptor)
        }

        let allSessions = freshSessions ?? program.sessions
        let completedInfo = allSessions.map { (dayName: $0.dayName, week: $0.weekNumber, isCompleted: $0.isCompleted) }

        guard let next = WorkoutEngine.nextDay(
            definition: def,
            currentWeek: program.currentWeek,
            completedSessions: completedInfo
        ) else { return }

        dayName = next.dayName
        weekNumber = next.week

        if next.week != program.currentWeek && !def.repeating {
            program.currentWeek = next.week
        }

        let heavyGroups = lastHeavyGroupCounts(program: program, week: weekNumber, sessions: freshSessions)
        groupMode = WorkoutEngine.groupCount(definition: def, dayName: next.dayName, week: weekNumber, heavyGroupCount: heavyGroups.values.min())
        setRestDuration = program.restBetweenSets
        seriesRestDuration = program.restBetweenSeries

        plannedExercises = WorkoutEngine.generateWorkout(
            definition: def,
            dayName: next.dayName,
            week: weekNumber,
            exercises: program.exercises
        )

        for exercise in plannedExercises {
            let heavyCount = heavyGroups[exercise.name]
            let mode = WorkoutEngine.groupCountForExercise(definition: def, dayName: next.dayName, week: weekNumber, exerciseName: exercise.name, heavyGroupCount: heavyCount)
            switch mode {
            case .fixed(let n): groupsPerExercise[exercise.name] = n
            case .max: groupsPerExercise[exercise.name] = 0
            }
        }
    }

    var hasWorkoutToday: Bool { !plannedExercises.isEmpty }

    func groupsPerExerciseCount(_ name: String) -> Int {
        let count = groupsPerExercise[name] ?? 0
        return count == 0 ? 5 : count
    }

    // MARK: - Group Info

    func groupModeForExercise(_ name: String) -> GroupMode {
        let count = groupsPerExercise[name] ?? 0
        return count == 0 ? .max : .fixed(count)
    }

    func currentGroupForExercise(_ name: String) -> Int {
        guard let session = activeSession else { return 0 }
        return session.completedSets
            .filter { $0.exerciseName == name }
            .map(\.groupNumber)
            .max() ?? 0
    }

    func completedGroupCount(for name: String) -> Int {
        activeSession?.fullyCompletedGroupCount(for: name) ?? 0
    }

    func canAddMoreGroups(for name: String) -> Bool {
        let mode = groupModeForExercise(name)
        let current = currentGroupForExercise(name)
        switch mode {
        case .max: return true
        case .fixed(let n): return current < n
        }
    }

    func allSetsCompleteForCurrentGroup(exerciseName: String) -> Bool {
        guard let session = activeSession else { return false }
        let current = currentGroupForExercise(exerciseName)
        guard current > 0 else { return false }
        let setsInGroup = session.completedSets.filter {
            $0.exerciseName == exerciseName && $0.groupNumber == current
        }
        return !setsInGroup.isEmpty && setsInGroup.allSatisfy(\.isCompleted)
    }

    func isExerciseDone(_ name: String) -> Bool {
        if doneExercises.contains(name) { return true }
        let mode = groupModeForExercise(name)
        if case .fixed = mode {
            guard let session = activeSession else { return false }
            let sets = session.completedSets.filter { $0.exerciseName == name }
            return !sets.isEmpty && sets.allSatisfy(\.isCompleted)
        }
        return false
    }

    func markExerciseDone(_ name: String) {
        doneExercises.insert(name)
    }

    // MARK: - Session Lifecycle

    func startWorkout(program: Program, modelContext: ModelContext) {
        let session = WorkoutSession(weekNumber: weekNumber, dayName: dayName)
        session.program = program
        program.sessions.append(session)
        modelContext.insert(session)

        activeSession = session
        isWorkoutActive = true
        doneExercises = []
        elapsedTime = 0
        startElapsedTimer()

        for exercise in plannedExercises {
            let mode = groupModeForExercise(exercise.name)
            let initialCount: Int
            switch mode {
            case .fixed(let n): initialCount = n
            case .max: initialCount = 5
            }
            for _ in 0..<initialCount {
                addGroup(for: exercise, to: session)
            }
        }
    }

    func addGroup(for exercise: PlannedWorkoutExercise, to session: WorkoutSession) {
        let nextGroup = currentGroupForExercise(exercise.name) + 1

        for (setIndex, set) in exercise.sets.enumerated() {
            let completedSet = CompletedSet(
                exerciseName: exercise.name,
                groupNumber: nextGroup,
                setNumber: setIndex + 1,
                targetWeight: set.weight,
                targetReps: set.reps,
                intensity: set.intensity,
                pushUpVariant: set.pushUpVariant
            )
            completedSet.session = session
            session.completedSets.append(completedSet)
        }
    }

    func addAnotherGroupForExercise(_ name: String) {
        guard let session = activeSession else { return }
        guard let exercise = plannedExercises.first(where: { $0.name == name }) else { return }
        guard canAddMoreGroups(for: name) else { return }
        addGroup(for: exercise, to: session)
    }

    func cancelWorkout(program: Program, modelContext: ModelContext) {
        guard let session = activeSession else { return }

        stopRestTimer()
        stopElapsedTimer()

        program.sessions.removeAll { $0.id == session.id }
        modelContext.delete(session)
        try? modelContext.save()

        activeSession = nil
        plannedExercises = []
        doneExercises = []
        isWorkoutActive = false

        prepareWorkout(program: program, modelContext: modelContext)
    }

    // MARK: - Set Actions

    func completeSet(_ set: CompletedSet) {
        set.isCompleted = true
        set.completedAt = .now
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let groupNum = set.groupNumber
        let name = set.exerciseName
        Task { @MainActor in
            let isGroup = allSetsCompleteInGroup(groupNum, exerciseName: name)
            startRestTimer(
                duration: isGroup ? seriesRestDuration : setRestDuration,
                exerciseName: name,
                isSeriesRest: isGroup
            )
        }
    }

    private func allSetsCompleteInGroup(_ group: Int, exerciseName: String) -> Bool {
        guard let session = activeSession else { return false }
        let setsInGroup = session.completedSets.filter {
            $0.exerciseName == exerciseName && $0.groupNumber == group
        }
        return !setsInGroup.isEmpty && setsInGroup.allSatisfy(\.isCompleted)
    }

    func uncompleteSet(_ set: CompletedSet) {
        set.isCompleted = false
        set.completedAt = nil
    }

    func updateActualReps(_ set: CompletedSet, reps: Int) {
        set.actualReps = reps
    }

    // MARK: - Finish

    func finishWorkout(program: Program, modelContext: ModelContext) {
        guard let session = activeSession else { return }
        session.isCompleted = true
        session.duration = elapsedTime

        stopRestTimer()
        stopElapsedTimer()

        try? modelContext.save()

        activeSession = nil
        doneExercises = []
        plannedExercises = []
        isWorkoutActive = false

        prepareWorkout(program: program, modelContext: modelContext)
    }

    // MARK: - Timer

    func skipRestTimer() { stopRestTimer() }

    private static let restNotificationID = "stronq-rest-timer"

    private func startRestTimer(duration: Int, exerciseName: String? = nil, isSeriesRest: Bool = false) {
        stopRestTimer()
        let endDate = Date.now.addingTimeInterval(TimeInterval(duration))
        restTimerRemaining = duration
        isRestTimerRunning = true

        let nextInfo = isSeriesRest ? "Group rest — \(exerciseName ?? "")" : "Set rest — \(exerciseName ?? "")"
        timerManager.startLiveActivity(
            exerciseName: exerciseName ?? "",
            nextSetInfo: nextInfo,
            duration: duration
        )
        scheduleRestNotification(in: duration, exerciseName: exerciseName ?? "")

        restTimerTask = Task {
            while !Task.isCancelled {
                let remaining = Int(endDate.timeIntervalSinceNow.rounded(.up))
                restTimerRemaining = max(remaining, 0)
                if remaining <= 0 { break }
                try? await Task.sleep(for: .seconds(1))
            }
            guard !Task.isCancelled else { return }
            isRestTimerRunning = false
            restTimerRemaining = 0
            timerManager.endLiveActivity()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func stopRestTimer() {
        restTimerTask?.cancel()
        restTimerTask = nil
        isRestTimerRunning = false
        restTimerRemaining = 0
        timerManager.endLiveActivity()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.restNotificationID])
    }

    private func scheduleRestNotification(in seconds: Int, exerciseName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Rest Complete"
        content.body = "Time for your next set — \(exerciseName)"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: Self.restNotificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func startElapsedTimer() {
        elapsedTimerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                elapsedTime += 1
            }
        }
    }

    private func stopElapsedTimer() {
        elapsedTimerTask?.cancel()
        elapsedTimerTask = nil
    }

    // MARK: - Helpers

    private func lastHeavyGroupCounts(program: Program, week: Int, sessions: [WorkoutSession]? = nil) -> [String: Int] {
        guard let def = program.definition else { return [:] }
        let heavyDayName = def.days.first?.name ?? "Heavy"
        let allSessions = sessions ?? program.sessions
        let heavySession = allSessions.first {
            $0.weekNumber == week && $0.dayName == heavyDayName && $0.isCompleted
        }
        guard let session = heavySession else { return [:] }

        var counts: [String: Int] = [:]
        for exercise in program.exercises {
            counts[exercise.name] = session.fullyCompletedGroupCount(for: exercise.name)
        }
        return counts
    }

    var formattedElapsed: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedRest: String {
        let minutes = restTimerRemaining / 60
        let seconds = restTimerRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func setsGroupedByGroup(for name: String) -> [(group: Int, sets: [CompletedSet])] {
        guard let session = activeSession else { return [] }
        let all = session.completedSets
            .filter { $0.exerciseName == name }
            .sorted { ($0.groupNumber, $0.setNumber) < ($1.groupNumber, $1.setNumber) }
        let grouped = Dictionary(grouping: all) { $0.groupNumber }
        return grouped.keys.sorted().map { g in
            (group: g, sets: grouped[g]!.sorted { $0.setNumber < $1.setNumber })
        }
    }
}
