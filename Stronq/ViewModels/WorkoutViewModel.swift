import SwiftUI
import SwiftData

@Observable
@MainActor
final class WorkoutViewModel {
    var activeSession: WorkoutSession?
    var isWorkoutActive = false
    var restTimerRemaining: Int = 0
    var isRestTimerRunning = false
    var elapsedTime: TimeInterval = 0

    var seriesMode: SeriesMode = .fixed(5)
    var plannedExercises: [PlannedSeriesExercise] = []
    var dayType: DayType = .heavy
    var weekNumber: Int = 1
    var doneExercises: Set<String> = []
    private var seriesPerExercise: [String: Int] = [:]

    private var restTimerTask: Task<Void, Never>?
    private var elapsedTimerTask: Task<Void, Never>?
    private var setRestDuration: Int = 60
    private var seriesRestDuration: Int = 180

    // MARK: - Setup

    func prepareWorkout(program: Program) {
        plannedExercises = []

        let calculatedWeek = DeLormeEngine.currentWeek(
            startDate: program.startDate,
            currentDate: .now,
            introCycleEnabled: program.introCycleEnabled
        )
        if calculatedWeek > program.currentWeek {
            program.currentWeek = calculatedWeek
        }

        guard let next = DeLormeEngine.nextWorkout(program: program) else { return }
        dayType = next.dayType
        weekNumber = next.week

        let mondaySeries = lastMondaySeriesCounts(program: program, week: weekNumber)
        seriesMode = DeLormeEngine.seriesCount(week: weekNumber, dayType: next.dayType, mondaySeriesCount: mondaySeries.values.min())
        setRestDuration = program.restBetweenSets
        seriesRestDuration = program.restBetweenSeries

        plannedExercises = DeLormeEngine.generateSeries(
            exercises: program.exercises,
            dayType: next.dayType,
            week: weekNumber
        )

        for exercise in plannedExercises {
            let mondayCount = mondaySeries[exercise.name]
            let mode = DeLormeEngine.seriesCount(week: weekNumber, dayType: next.dayType, mondaySeriesCount: mondayCount)
            switch mode {
            case .fixed(let n): seriesPerExercise[exercise.name] = n
            case .max: seriesPerExercise[exercise.name] = 0
            }
        }
    }

    var hasWorkoutToday: Bool { !plannedExercises.isEmpty }

    // MARK: - Series Info

    func seriesModeForExercise(_ name: String) -> SeriesMode {
        let count = seriesPerExercise[name] ?? 0
        return count == 0 ? .max : .fixed(count)
    }

    func currentSeriesForExercise(_ name: String) -> Int {
        guard let session = activeSession else { return 0 }
        return session.completedSets
            .filter { $0.exerciseName == name }
            .map(\.seriesNumber)
            .max() ?? 0
    }

    func canAddMoreSeries(for name: String) -> Bool {
        let mode = seriesModeForExercise(name)
        let current = currentSeriesForExercise(name)
        switch mode {
        case .max: return true
        case .fixed(let n): return current < n
        }
    }

    func allSetsCompleteForCurrentSeries(exerciseName: String) -> Bool {
        guard let session = activeSession else { return false }
        let current = currentSeriesForExercise(exerciseName)
        guard current > 0 else { return false }
        let setsInSeries = session.completedSets.filter {
            $0.exerciseName == exerciseName && $0.seriesNumber == current
        }
        return !setsInSeries.isEmpty && setsInSeries.allSatisfy(\.isCompleted)
    }

    func isExerciseDone(_ name: String) -> Bool {
        if doneExercises.contains(name) { return true }
        let mode = seriesModeForExercise(name)
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
        let session = WorkoutSession(weekNumber: weekNumber, dayType: dayType)
        session.program = program
        program.sessions.append(session)
        modelContext.insert(session)

        activeSession = session
        isWorkoutActive = true
        doneExercises = []
        elapsedTime = 0
        startElapsedTimer()

        for exercise in plannedExercises {
            let mode = seriesModeForExercise(exercise.name)
            let initialCount: Int
            switch mode {
            case .fixed(let n): initialCount = n
            case .max: initialCount = 5
            }
            for _ in 0..<initialCount {
                addSeries(for: exercise, to: session)
            }
        }
    }

    func addSeries(for exercise: PlannedSeriesExercise, to session: WorkoutSession) {
        let nextSeries = currentSeriesForExercise(exercise.name) + 1

        for (setIndex, set) in exercise.sets.enumerated() {
            let completedSet = CompletedSet(
                exerciseName: exercise.name,
                seriesNumber: nextSeries,
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

    func addAnotherSeriesForExercise(_ name: String) {
        guard let session = activeSession else { return }
        guard let exercise = plannedExercises.first(where: { $0.name == name }) else { return }
        guard canAddMoreSeries(for: name) else { return }
        addSeries(for: exercise, to: session)
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

        prepareWorkout(program: program)
    }

    // MARK: - Set Actions

    func completeSet(_ set: CompletedSet) {
        set.isCompleted = true
        set.completedAt = .now
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if allSetsCompleteInSeries(set.seriesNumber, exerciseName: set.exerciseName) {
            startRestTimer(duration: seriesRestDuration)
        } else {
            startRestTimer(duration: setRestDuration)
        }
    }

    private func allSetsCompleteInSeries(_ series: Int, exerciseName: String) -> Bool {
        guard let session = activeSession else { return false }
        let setsInSeries = session.completedSets.filter {
            $0.exerciseName == exerciseName && $0.seriesNumber == series
        }
        return !setsInSeries.isEmpty && setsInSeries.allSatisfy(\.isCompleted)
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

        prepareWorkout(program: program)
    }

    // MARK: - Timer

    func skipRestTimer() { stopRestTimer() }

    private func startRestTimer(duration: Int) {
        stopRestTimer()
        restTimerRemaining = duration
        isRestTimerRunning = true

        restTimerTask = Task {
            while restTimerRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                restTimerRemaining -= 1
            }
            isRestTimerRunning = false
            if restTimerRemaining == 0 {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }

    private func stopRestTimer() {
        restTimerTask?.cancel()
        restTimerTask = nil
        isRestTimerRunning = false
        restTimerRemaining = 0
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

    private func lastMondaySeriesCounts(program: Program, week: Int) -> [String: Int] {
        let mondaySession = program.sessions.first {
            $0.weekNumber == week && $0.dayType == .heavy && $0.isCompleted
        }
        guard let session = mondaySession else { return [:] }

        var counts: [String: Int] = [:]
        for exercise in program.exercises {
            counts[exercise.name] = session.completedSets
                .filter { $0.exerciseName == exercise.name }
                .map(\.seriesNumber)
                .max() ?? 0
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

    func setsGroupedBySeries(for name: String) -> [(series: Int, sets: [CompletedSet])] {
        guard let session = activeSession else { return [] }
        let all = session.completedSets
            .filter { $0.exerciseName == name }
            .sorted { ($0.seriesNumber, $0.setNumber) < ($1.seriesNumber, $1.setNumber) }
        let grouped = Dictionary(grouping: all) { $0.seriesNumber }
        return grouped.keys.sorted().map { s in
            (series: s, sets: grouped[s]!.sorted { $0.setNumber < $1.setNumber })
        }
    }
}
