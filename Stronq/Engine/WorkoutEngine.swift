import Foundation

// MARK: - Supporting Types

enum GroupMode: Equatable, Sendable {
    case fixed(Int)
    case max
}

struct PlannedWorkoutExercise: Sendable {
    let name: String
    let type: ExerciseType
    let sets: [PlannedSet]
    let unit: WeightUnit
}

// MARK: - WorkoutEngine

struct WorkoutEngine {

    // MARK: - Intensity Levels

    static func intensityLevels(
        definition: ProgramDefinition,
        dayName: String,
        week: Int
    ) -> [Double] {
        // Check intro overrides first
        if let overrides = definition.introOverrides {
            for weekOverride in overrides {
                if weekOverride.week == week,
                   let dayOverride = weekOverride.dayOverrides.first(where: { $0.dayName == dayName }) {
                    return dayOverride.intensities
                }
            }
        }

        // Fall back to the day's first exercise slot's first set group
        guard let day = definition.days.first(where: { $0.name == dayName }),
              let firstSlot = day.exerciseSlots.first,
              let firstGroup = firstSlot.setGroups.first else {
            return []
        }
        return firstGroup.sets.map(\.intensity)
    }

    // MARK: - Group Count

    static func groupCount(
        definition: ProgramDefinition,
        dayName: String,
        week: Int,
        heavyGroupCount: Int?
    ) -> GroupMode {
        // Check intro overrides first
        if let overrides = definition.introOverrides {
            for weekOverride in overrides {
                if weekOverride.week == week,
                   let dayOverride = weekOverride.dayOverrides.first(where: { $0.dayName == dayName }) {
                    return .fixed(dayOverride.groupCount)
                }
            }
        }

        // Fall back to the day's first exercise slot's first set group repeatCount
        guard let day = definition.days.first(where: { $0.name == dayName }),
              let firstSlot = day.exerciseSlots.first,
              let firstGroup = firstSlot.setGroups.first else {
            return .fixed(1)
        }

        switch firstGroup.repeatCount {
        case .fixed(let n):
            return .fixed(n)
        case .max:
            return .max
        case .matchDay:
            return .fixed(heavyGroupCount ?? 5)
        }
    }

    static func groupCountForExercise(
        definition: ProgramDefinition,
        dayName: String,
        week: Int,
        exerciseName: String,
        heavyGroupCount: Int?
    ) -> GroupMode {
        // Check intro overrides first
        if let overrides = definition.introOverrides {
            for weekOverride in overrides {
                if weekOverride.week == week,
                   let dayOverride = weekOverride.dayOverrides.first(where: { $0.dayName == dayName }) {
                    return .fixed(dayOverride.groupCount)
                }
            }
        }

        // Try to find the specific exercise's slot
        guard let day = definition.days.first(where: { $0.name == dayName }) else {
            return .fixed(1)
        }

        let slot = day.exerciseSlots.first(where: { slot in
            slot.defaultExercise == exerciseName || slot.alternatives.contains(exerciseName)
        }) ?? day.exerciseSlots.first

        guard let resolvedSlot = slot,
              let firstGroup = resolvedSlot.setGroups.first else {
            return .fixed(1)
        }

        switch firstGroup.repeatCount {
        case .fixed(let n):
            return .fixed(n)
        case .max:
            return .max
        case .matchDay:
            return .fixed(heavyGroupCount ?? 5)
        }
    }

    // MARK: - Workout Generation

    static func generateWorkout(
        definition: ProgramDefinition,
        dayName: String,
        week: Int,
        exercises: [Exercise]
    ) -> [PlannedWorkoutExercise] {
        let intensities = intensityLevels(definition: definition, dayName: dayName, week: week)

        return exercises
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { exercise in
                let rm = exercise.initial10RM
                let sets = intensities.map { intensity in
                    PlannedSet(
                        intensity: intensity,
                        weight: rm * intensity,
                        reps: 5,
                        pushUpVariant: exercise.type == .bodyweight
                            ? PushUpVariant.forIntensity(intensity, maxLevel: exercise.startingPushUpVariant)
                            : nil
                    )
                }
                return PlannedWorkoutExercise(
                    name: exercise.displayName,
                    type: exercise.type,
                    sets: sets,
                    unit: exercise.unit
                )
            }
    }

    // MARK: - Progression

    static func applyProgression(
        rule: ProgressionRule,
        initial10RM: Double,
        unit: WeightUnit,
        completedGroupCounts: [Bool]
    ) -> Double {
        var rm = initial10RM
        for completed in completedGroupCounts {
            if completed {
                switch rule.action {
                case .addWeight(let kg, let lbs):
                    rm += unit == .kg ? kg : lbs
                case .percentageIncrease(let pct):
                    rm *= (1.0 + pct)
                }
            }
        }
        return rm
    }

    // MARK: - Schedule

    static func nextDay(
        definition: ProgramDefinition,
        currentWeek: Int,
        completedSessions: [(dayName: String, week: Int, isCompleted: Bool)]
    ) -> (dayName: String, week: Int)? {
        var week = currentWeek
        let cycleLength = definition.cycleLength ?? 1

        if week > cycleLength { return nil }

        // In the final week, only the first day is available
        let dayNames: [String] = week == cycleLength
            ? [definition.days[0].name]
            : definition.days.map(\.name)

        for dayName in dayNames {
            let done = completedSessions.contains {
                $0.dayName == dayName && $0.week == week && $0.isCompleted
            }
            if !done { return (dayName, week) }
        }

        // All days done this week, advance
        week += 1
        if !definition.repeating && week > cycleLength { return nil }
        if definition.repeating {
            let firstWeek = definition.introCycle != nil ? -1 : 1
            week = firstWeek
        }
        return (definition.days[0].name, week)
    }

    // MARK: - Suggested Day

    static func suggestedDay(
        definition: ProgramDefinition,
        dayName: String
    ) -> String {
        guard let day = definition.days.first(where: { $0.name == dayName }),
              let weekday = day.suggestedWeekday else {
            return ""
        }
        let formatter = DateFormatter()
        let weekdayName = formatter.weekdaySymbols[weekday - 1]
        return "Usually \(weekdayName)"
    }

    // MARK: - Current Week

    static func currentWeek(
        startDate: Date,
        currentDate: Date,
        definition: ProgramDefinition
    ) -> Int {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: currentDate).weekOfYear ?? 0
        let firstWeek = definition.introCycle != nil ? -1 : 1
        let cycleLength = definition.cycleLength ?? 1
        return min(firstWeek + weeks, cycleLength)
    }
}
