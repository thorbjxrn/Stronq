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

    var currentSeriesNumber: Int = 0
    var seriesMode: SeriesMode = .fixed(5)
    var plannedExercises: [PlannedSeriesExercise] = []
    var dayType: DayType = .heavy
    var weekNumber: Int = 1

    private var restTimerTask: Task<Void, Never>?
    private var elapsedTimerTask: Task<Void, Never>?
    private var setRestDuration: Int = 60
    private var seriesRestDuration: Int = 180

    // MARK: - Setup

    func prepareWorkout(program: Program) {
        let today = Date.now
        weekNumber = DeLormeEngine.currentWeek(
            startDate: program.startDate,
            currentDate: today,
            introCycleEnabled: program.introCycleEnabled
        )

        guard let dt = DeLormeEngine.dayType(for: today) else { return }
        dayType = dt

        if program.session(week: weekNumber, dayType: dt)?.isCompleted == true {
            return
        }

        let mondaySeries = lastMondaySeriesCount(program: program, week: weekNumber)
        seriesMode = DeLormeEngine.seriesCount(week: weekNumber, dayType: dt, mondaySeriesCount: mondaySeries)
        setRestDuration = program.setRestDuration
        seriesRestDuration = program.seriesRestDuration

        plannedExercises = DeLormeEngine.generateSeries(
            exercises: program.exercises,
            dayType: dt,
            week: weekNumber
        )
    }

    var hasWorkoutToday: Bool { !plannedExercises.isEmpty }

    var targetSeriesCount: Int? {
        switch seriesMode {
        case .fixed(let n): return n
        case .max: return nil
        }
    }

    // MARK: - Session Lifecycle

    func startWorkout(program: Program, modelContext: ModelContext) {
        let session = WorkoutSession(weekNumber: weekNumber, dayType: dayType)
        session.program = program
        program.sessions.append(session)
        modelContext.insert(session)

        activeSession = session
        isWorkoutActive = true
        currentSeriesNumber = 0
        elapsedTime = 0
        startElapsedTimer()

        addNextSeries(to: session)
    }

    func addNextSeries(to session: WorkoutSession) {
        currentSeriesNumber += 1

        for exercise in plannedExercises {
            for (setIndex, set) in exercise.sets.enumerated() {
                let completedSet = CompletedSet(
                    exerciseName: exercise.name,
                    seriesNumber: currentSeriesNumber,
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
    }

    var canAddMoreSeries: Bool {
        switch seriesMode {
        case .fixed(let n): return currentSeriesNumber < n
        case .max: return true
        }
    }

    var currentSeriesComplete: Bool {
        guard let session = activeSession else { return false }
        let setsInCurrentSeries = session.completedSets.filter { $0.seriesNumber == currentSeriesNumber }
        return !setsInCurrentSeries.isEmpty && setsInCurrentSeries.allSatisfy(\.isCompleted)
    }

    func addAnotherSeries() {
        guard let session = activeSession, canAddMoreSeries else { return }
        addNextSeries(to: session)
    }

    // MARK: - Set Actions

    func completeSet(_ set: CompletedSet) {
        set.isCompleted = true
        set.completedAt = .now
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if currentSeriesComplete {
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

    private func lastMondaySeriesCount(program: Program, week: Int) -> Int? {
        let mondaySession = program.sessions.first {
            $0.weekNumber == week && $0.dayType == .heavy && $0.isCompleted
        }
        guard let session = mondaySession else { return nil }
        let maxSeries = session.completedSets.map(\.seriesNumber).max() ?? 0
        return maxSeries
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

    func setsForCurrentSeries() -> [CompletedSet] {
        guard let session = activeSession else { return [] }
        return session.completedSets
            .filter { $0.seriesNumber == currentSeriesNumber }
            .sorted { ($0.exerciseName, $0.setNumber) < ($1.exerciseName, $1.setNumber) }
    }

    func allSetsGroupedBySeries() -> [(series: Int, sets: [CompletedSet])] {
        guard let session = activeSession else { return [] }
        let grouped = Dictionary(grouping: session.completedSets) { $0.seriesNumber }
        return grouped.keys.sorted().map { series in
            (series: series, sets: grouped[series]!.sorted {
                ($0.exerciseName, $0.setNumber) < ($1.exerciseName, $1.setNumber)
            })
        }
    }
}
