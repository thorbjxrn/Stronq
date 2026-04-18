import SwiftUI
import SwiftData

@Observable
@MainActor
final class WorkoutViewModel {
    var plannedWorkout: PlannedWorkout?
    var activeSession: WorkoutSession?
    var isWorkoutActive = false
    var restTimerRemaining: Int = 0
    var isRestTimerRunning = false
    var elapsedTime: TimeInterval = 0

    private var restTimerTask: Task<Void, Never>?
    private var elapsedTimerTask: Task<Void, Never>?
    private var restDuration: Int = 90

    func generateTodayWorkout(program: Program) {
        let today = Date.now
        let week = DeLormeEngine.currentWeek(
            startDate: program.startDate,
            currentDate: today,
            introCycleEnabled: program.introCycleEnabled
        )

        guard let dayType = DeLormeEngine.dayType(for: today, startDate: program.startDate) else {
            plannedWorkout = nil
            return
        }

        if program.session(week: week, dayType: dayType)?.isCompleted == true {
            plannedWorkout = nil
            return
        }

        let seriesHistory = buildSeriesHistory(program: program)
        restDuration = program.restTimerDuration

        plannedWorkout = DeLormeEngine.generateWorkout(
            exercises: program.exercises,
            week: week,
            dayType: dayType,
            seriesHistory: seriesHistory
        )
    }

    func startWorkout(program: Program, modelContext: ModelContext) {
        guard let planned = plannedWorkout else { return }

        let session = WorkoutSession(
            weekNumber: planned.week,
            dayType: planned.dayType
        )
        session.program = program
        program.sessions.append(session)

        for exercise in planned.exercises {
            for series in 0..<exercise.seriesCount {
                for (setIndex, set) in exercise.sets.enumerated() {
                    let completedSet = CompletedSet(
                        exerciseName: exercise.name,
                        seriesNumber: series,
                        setNumber: setIndex,
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

        modelContext.insert(session)
        activeSession = session
        isWorkoutActive = true
        elapsedTime = 0
        startElapsedTimer()
    }

    func completeSet(_ set: CompletedSet) {
        set.isCompleted = true
        set.completedAt = .now

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        startRestTimer()
    }

    func uncompleteSet(_ set: CompletedSet) {
        set.isCompleted = false
        set.completedAt = nil
    }

    func updateActualWeight(_ set: CompletedSet, weight: Double) {
        set.actualWeight = weight
    }

    func updateActualReps(_ set: CompletedSet, reps: Int) {
        set.actualReps = reps
    }

    func finishWorkout(modelContext: ModelContext) {
        guard let session = activeSession else { return }
        session.isCompleted = true
        session.duration = elapsedTime

        stopRestTimer()
        stopElapsedTimer()
        isWorkoutActive = false

        try? modelContext.save()
    }

    func skipRestTimer() {
        stopRestTimer()
    }

    // MARK: - Timer

    private func startRestTimer() {
        stopRestTimer()
        restTimerRemaining = restDuration
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

    private func buildSeriesHistory(program: Program) -> [String: [Int]] {
        var history: [String: [Int]] = [:]
        let sortedSessions = program.sessions
            .filter { $0.isCompleted }
            .sorted { $0.weekNumber < $1.weekNumber }

        for exercise in program.exercises {
            var weeklyHistory: [Int] = []
            for week in 1...6 {
                let session = sortedSessions.first {
                    $0.weekNumber == week && $0.dayType == .heavy
                }
                let completed = session?.maxSeriesCompleted(for: exercise.name) ?? 5
                weeklyHistory.append(completed)
            }
            history[exercise.name] = weeklyHistory
        }
        return history
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
}
