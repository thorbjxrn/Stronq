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
    var currentExerciseIndex: Int = 0
    var seriesPerExercise: [String: Int] = [:]
    var exerciseOrder: ExerciseOrder = .sequential
    var currentAlternatingSeries: Int = 0

    private var restTimerTask: Task<Void, Never>?
    private var elapsedTimerTask: Task<Void, Never>?
    private var setRestDuration: Int = 60
    private var seriesRestDuration: Int = 180

    // MARK: - Setup

    func prepareWorkout(program: Program) {
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
        setRestDuration = program.setRestDuration
        seriesRestDuration = program.seriesRestDuration
        exerciseOrder = program.exerciseOrder

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

    var currentExercise: PlannedSeriesExercise? {
        guard currentExerciseIndex < plannedExercises.count else { return nil }
        return plannedExercises[currentExerciseIndex]
    }

    var isLastExercise: Bool {
        currentExerciseIndex >= plannedExercises.count - 1
    }

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

    // MARK: - Session Lifecycle

    func startWorkout(program: Program, modelContext: ModelContext) {
        let session = WorkoutSession(weekNumber: weekNumber, dayType: dayType)
        session.program = program
        program.sessions.append(session)
        modelContext.insert(session)

        activeSession = session
        isWorkoutActive = true
        currentExerciseIndex = 0
        currentAlternatingSeries = 0
        elapsedTime = 0
        startElapsedTimer()

        if exerciseOrder == .alternating {
            currentAlternatingSeries = 1
            for exercise in plannedExercises {
                addSeries(for: exercise, to: session)
            }
        } else if let exercise = currentExercise {
            addSeries(for: exercise, to: session)
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

    func addAnotherSeries() {
        guard let session = activeSession else { return }
        if exerciseOrder == .alternating {
            currentAlternatingSeries += 1
            for exercise in plannedExercises {
                if canAddMoreSeries(for: exercise.name) {
                    addSeries(for: exercise, to: session)
                }
            }
        } else {
            guard let exercise = currentExercise else { return }
            guard canAddMoreSeries(for: exercise.name) else { return }
            addSeries(for: exercise, to: session)
        }
    }

    func moveToNextExercise() {
        guard let session = activeSession else { return }
        currentExerciseIndex += 1
        if let exercise = currentExercise {
            addSeries(for: exercise, to: session)
        }
    }

    // MARK: - Set Actions

    func completeSet(_ set: CompletedSet) {
        set.isCompleted = true
        set.completedAt = .now
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if allSetsCompleteForCurrentSeries(exerciseName: set.exerciseName) {
            startRestTimer(duration: seriesRestDuration)
        } else {
            startRestTimer(duration: setRestDuration)
        }
    }

    func uncompleteSet(_ set: CompletedSet) {
        set.isCompleted = false
        set.completedAt = nil
    }

    func updateActualReps(_ set: CompletedSet, reps: Int) {
        set.actualReps = reps
    }

    // MARK: - Finish

    func finishWorkout(modelContext: ModelContext) {
        guard let session = activeSession else { return }
        session.isCompleted = true
        session.duration = elapsedTime

        stopRestTimer()
        stopElapsedTimer()
        isWorkoutActive = false

        try? modelContext.save()
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

    func setsForExercise(_ name: String) -> [CompletedSet] {
        guard let session = activeSession else { return [] }
        return session.completedSets
            .filter { $0.exerciseName == name }
            .sorted { ($0.seriesNumber, $0.setNumber) < ($1.seriesNumber, $1.setNumber) }
    }

    func setsGroupedBySeries(for name: String) -> [(series: Int, sets: [CompletedSet])] {
        let all = setsForExercise(name)
        let grouped = Dictionary(grouping: all) { $0.seriesNumber }
        return grouped.keys.sorted().map { s in
            (series: s, sets: grouped[s]!.sorted { $0.setNumber < $1.setNumber })
        }
    }
}
