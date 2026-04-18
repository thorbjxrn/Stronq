import Foundation

struct DeLormeEngine {

    // MARK: - Workout Generation

    static func generateWorkout(
        exercises: [Exercise],
        week: Int,
        dayType: DayType,
        seriesHistory: [String: [Int]]
    ) -> PlannedWorkout {
        let plannedExercises = exercises
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { exercise in
                generatePlannedExercise(
                    exercise: exercise,
                    week: week,
                    dayType: dayType,
                    seriesHistory: seriesHistory[exercise.name] ?? []
                )
            }
        return PlannedWorkout(week: week, dayType: dayType, exercises: plannedExercises)
    }

    private static func generatePlannedExercise(
        exercise: Exercise,
        week: Int,
        dayType: DayType,
        seriesHistory: [Int]
    ) -> PlannedExercise {
        let intensities = intensityLevels(for: dayType, week: week)
        let series = seriesCount(week: week, dayType: dayType, exerciseType: exercise.type)
        let currentRM = calculate10RM(
            initial10RM: exercise.initial10RM,
            increment: exercise.weightIncrement,
            weeklySeriesHistory: seriesHistory,
            currentWeek: week
        )
        let nextRM = calculate10RM(
            initial10RM: exercise.initial10RM,
            increment: exercise.weightIncrement,
            weeklySeriesHistory: seriesHistory,
            currentWeek: week + 1
        )

        let sets = intensities.enumerated().map { index, intensity in
            let weight = calculateSetWeight(
                tenRM: currentRM,
                nextWeekTenRM: nextRM,
                dayType: dayType,
                intensity: intensity,
                week: week
            )
            return PlannedSet(
                intensity: intensity,
                weight: weight,
                reps: 5,
                pushUpVariant: exercise.type == .bodyweight ? PushUpVariant.from(intensity: intensity) : nil
            )
        }

        return PlannedExercise(
            name: exercise.name,
            type: exercise.type,
            sets: sets,
            seriesCount: Int(ceil(series)),
            unit: exercise.unit
        )
    }

    // MARK: - 10RM Calculation

    static func calculate10RM(
        initial10RM: Double,
        increment: Double,
        weeklySeriesHistory: [Int],
        currentWeek: Int
    ) -> Double {
        guard currentWeek >= 1 else { return initial10RM }

        var rm = initial10RM
        for weekIndex in 1..<currentWeek {
            let historyIndex = weekIndex - 1
            let completedSeries = historyIndex < weeklySeriesHistory.count
                ? weeklySeriesHistory[historyIndex]
                : 5
            if completedSeries >= 5 {
                rm += increment
            }
        }
        return rm
    }

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

    static func calculateSetWeight(
        tenRM: Double,
        nextWeekTenRM: Double,
        dayType: DayType,
        intensity: Double,
        week: Int
    ) -> Double {
        if week <= 0 {
            return tenRM * intensity
        }

        switch dayType {
        case .heavy:
            return tenRM * intensity
        case .light, .medium:
            return nextWeekTenRM * intensity
        }
    }

    // MARK: - Series Count

    static func seriesCount(
        week: Int,
        dayType: DayType,
        exerciseType: ExerciseType
    ) -> Double {
        switch week {
        case -1:
            switch dayType {
            case .heavy: return 3
            case .light: return 4
            case .medium: return 5
            }
        case 0:
            switch dayType {
            case .heavy: return 2
            case .light: return 7
            case .medium: return 5
            }
        case 1, 2:
            return 5
        case 3:
            return exerciseType == .bodyweight ? 3.2 : 5
        case 4:
            return exerciseType == .bodyweight ? 4 : 5
        case 5:
            return 5
        case 6:
            return exerciseType == .bodyweight ? 4 : 5
        case 7:
            return 5
        default:
            return 5
        }
    }

    // MARK: - Accessories

    struct AccessorySet {
        let exercises: [String]
    }

    static func accessories(for dayType: DayType) -> AccessorySet {
        switch dayType {
        case .heavy:
            AccessorySet(exercises: ["Lateral Raises", "Triceps Extension", "Neck"])
        case .light:
            AccessorySet(exercises: ["Lateral Raises", "Overhead Press", "Abs"])
        case .medium:
            AccessorySet(exercises: ["Lateral Raises", "Cable Crossover", "Rear Deltoids"])
        }
    }

    // MARK: - Schedule

    static func dayType(for date: Date, startDate: Date) -> DayType? {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 2: return .heavy   // Monday
        case 4: return .light   // Wednesday
        case 6: return .medium  // Friday
        default: return nil
        }
    }

    static func currentWeek(startDate: Date, currentDate: Date, introCycleEnabled: Bool) -> Int {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: currentDate).weekOfYear ?? 0
        let firstWeek = introCycleEnabled ? -1 : 1
        return min(firstWeek + weeks, 7)
    }

    static func nextWorkoutDate(from date: Date) -> (Date, DayType)? {
        let calendar = Calendar.current
        var checkDate = date

        for _ in 0..<7 {
            checkDate = calendar.date(byAdding: .day, value: 1, to: checkDate)!
            if let dayType = dayType(for: checkDate, startDate: date) {
                return (checkDate, dayType)
            }
        }
        return nil
    }
}
