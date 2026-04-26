import Foundation

extension ProgramDefinition {
    static let candito6Week = ProgramDefinition(
        id: "candito-6week",
        name: "Candito 6-Week",
        description: "Periodized strength — conditioning to peak in 6 weeks",
        isPremium: true,
        cycleLength: 6,
        repeating: false,
        introCycle: nil,
        weekOverrides: canditoWeekOverrides,
        days: [
            // MARK: - Upper
            DayDefinition(
                name: "Upper",
                shortLabel: "U",
                suggestedWeekday: 2,
                exerciseSlots: [
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Bench Press",
                        alternatives: ["Dumbbell Bench Press", "Incline Bench Press"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.97, reps: 1)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Overhead Press",
                        alternatives: ["Dumbbell Shoulder Press", "Push Press"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.97, reps: 1)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Barbell Row",
                        alternatives: ["Dumbbell Row", "Seated Cable Row"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.97, reps: 1)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Lat Pulldown",
                        alternatives: ["Pull-up", "Chin-up"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.97, reps: 1)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                ]
            ),

            // MARK: - Lower
            DayDefinition(
                name: "Lower",
                shortLabel: "L",
                suggestedWeekday: 4,
                exerciseSlots: [
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Back Squat",
                        alternatives: ["Front Squat", "Goblet Squat"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.97, reps: 1)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 5.0, lbs: 10.0))
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Deadlift",
                        alternatives: ["Romanian Deadlift", "Sumo Deadlift"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.97, reps: 1)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 5.0, lbs: 10.0))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Leg Press",
                        alternatives: ["Hack Squat", "Bulgarian Split Squat"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.97, reps: 1)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 5.0, lbs: 10.0))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Leg Curl",
                        alternatives: ["Romanian Deadlift", "Glute Ham Raise"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.97, reps: 1)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                ]
            ),
        ]
    )

    // MARK: - Candito Week Overrides

    static let canditoWeekOverrides: [WeekOverride] = [
        // Week 1: Muscular Conditioning
        WeekOverride(week: 1, dayOverrides: [
            .init(dayName: "Upper", intensities: [0.70], groupCount: 3, reps: 10),
            .init(dayName: "Lower", intensities: [0.70], groupCount: 3, reps: 10),
        ]),
        // Week 2: Muscular Conditioning
        WeekOverride(week: 2, dayOverrides: [
            .init(dayName: "Upper", intensities: [0.75], groupCount: 3, reps: 10),
            .init(dayName: "Lower", intensities: [0.75], groupCount: 3, reps: 10),
        ]),
        // Week 3: Linear Progression
        WeekOverride(week: 3, dayOverrides: [
            .init(dayName: "Upper", intensities: [0.80], groupCount: 4, reps: 6),
            .init(dayName: "Lower", intensities: [0.80], groupCount: 4, reps: 6),
        ]),
        // Week 4: Linear Progression
        WeekOverride(week: 4, dayOverrides: [
            .init(dayName: "Upper", intensities: [0.85], groupCount: 4, reps: 6),
            .init(dayName: "Lower", intensities: [0.85], groupCount: 4, reps: 6),
        ]),
        // Week 5: Intense Strength
        WeekOverride(week: 5, dayOverrides: [
            .init(dayName: "Upper", intensities: [0.90], groupCount: 5, reps: 3),
            .init(dayName: "Lower", intensities: [0.90], groupCount: 5, reps: 3),
        ]),
        // Week 6 (peak) uses base definition: 3x1 @ 97%
    ]
}
