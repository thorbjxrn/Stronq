import Foundation

struct DeLormeEngine {

    // MARK: - Intensity Levels

    static func intensityLevels(for dayType: DayType, week: Int) -> [Double] {
        if week == -1 {
            return [0.5, 0.75]
        }
        if week == 0 {
            return dayType == .heavy ? [0.5, 0.75, 1.0] : [0.5, 0.75]
        }
        return dayType.intensityLevels
    }

    // MARK: - Weight Calculation

    static func calculateWeight(tenRM: Double, intensity: Double) -> Double {
        tenRM * intensity
    }

    // MARK: - 10RM Progression

    static func calculate10RM(
        initial10RM: Double,
        increment: Double,
        completedFiveSeries: [Bool]
    ) -> Double {
        var rm = initial10RM
        for completed in completedFiveSeries {
            if completed {
                rm += increment
            }
        }
        return rm
    }

    // MARK: - Series Count

    static func seriesCount(
        week: Int,
        dayType: DayType,
        mondaySeriesCount: Int?
    ) -> SeriesMode {
        switch week {
        case -1:
            switch dayType {
            case .heavy: return .fixed(3)
            case .light: return .fixed(4)
            case .medium: return .fixed(5)
            }
        case 0:
            switch dayType {
            case .heavy: return .fixed(2)
            case .light: return .fixed(7)
            case .medium: return .fixed(5)
            }
        default:
            switch dayType {
            case .heavy:
                return .max
            case .light, .medium:
                return .fixed(mondaySeriesCount ?? 5)
            }
        }
    }

    // MARK: - Workout Generation

    static func generateSeries(
        exercises: [Exercise],
        dayType: DayType,
        week: Int
    ) -> [PlannedSeriesExercise] {
        let intensities = intensityLevels(for: dayType, week: week)

        return exercises
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { exercise in
                let rm = exercise.initial10RM
                let sets = intensities.map { intensity in
                    PlannedSet(
                        intensity: intensity,
                        weight: calculateWeight(tenRM: rm, intensity: intensity),
                        reps: 5,
                        pushUpVariant: exercise.type == .bodyweight ? PushUpVariant.from(intensity: intensity) : nil
                    )
                }
                return PlannedSeriesExercise(
                    name: exercise.name,
                    type: exercise.type,
                    sets: sets,
                    unit: exercise.unit
                )
            }
    }

    // MARK: - Schedule

    static func nextWorkout(program: Program, sessions: [WorkoutSession]? = nil) -> (dayType: DayType, week: Int)? {
        var week = program.currentWeek
        if week > 7 { return nil }

        let allSessions = sessions ?? program.sessions

        let sequence: [DayType] = week == 7 ? [.heavy] : [.heavy, .light, .medium]
        for dayType in sequence {
            let done = allSessions.first {
                $0.weekNumber == week && $0.dayType == dayType && $0.isCompleted
            } != nil
            if !done { return (dayType, week) }
        }

        week += 1
        if week > 7 { return nil }
        program.currentWeek = week
        return (.heavy, week)
    }

    static func suggestedDay(for dayType: DayType) -> String {
        switch dayType {
        case .heavy: "Usually Monday"
        case .light: "Usually Wednesday"
        case .medium: "Usually Friday"
        }
    }

    static func currentWeek(startDate: Date, currentDate: Date, introCycleEnabled: Bool) -> Int {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: currentDate).weekOfYear ?? 0
        let firstWeek = introCycleEnabled ? -1 : 1
        return min(firstWeek + weeks, 7)
    }
}

// MARK: - Types

enum SeriesMode: Equatable {
    case fixed(Int)
    case max
}

struct PlannedSeriesExercise {
    let name: String
    let type: ExerciseType
    let sets: [PlannedSet]
    let unit: WeightUnit
}
