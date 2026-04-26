import Foundation

extension ProgramDefinition {

    static let delormeClassic = ProgramDefinition(
        id: "classic",
        name: "DeLorme Classic",
        description: "Bench Press + Deadlift",
        isPremium: false,
        cycleLength: 7,
        repeating: false,
        introCycle: IntroCycle(weeks: 2, volumeMultiplier: 1.0),
        weekOverrides: Self.delormeWeekOverrides,
        days: [
            // MARK: - Heavy
            DayDefinition(
                name: "Heavy",
                shortLabel: "H",
                suggestedWeekday: 2,
                exerciseSlots: [
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Bench Press",
                        alternatives: [
                            "Dumbbell Bench Press",
                            "Incline Bench Press",
                            "Floor Press",
                            "Close-Grip Bench Press",
                        ],
                        setGroups: [
                            SetGroup(
                                sets: [
                                    SetScheme(intensity: 0.50, reps: 5),
                                    SetScheme(intensity: 0.75, reps: 5),
                                    SetScheme(intensity: 1.00, reps: 5),
                                ],
                                repeatCount: .max
                            ),
                        ],
                        progression: ProgressionRule(
                            trigger: .completeNGroups(n: 5),
                            action: .addWeight(kg: 2.5, lbs: 5.0)
                        )
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Deadlift",
                        alternatives: [
                            "Romanian Deadlift",
                            "Sumo Deadlift",
                            "Trap Bar Deadlift",
                        ],
                        setGroups: [
                            SetGroup(
                                sets: [
                                    SetScheme(intensity: 0.50, reps: 5),
                                    SetScheme(intensity: 0.75, reps: 5),
                                    SetScheme(intensity: 1.00, reps: 5),
                                ],
                                repeatCount: .max
                            ),
                        ],
                        progression: ProgressionRule(
                            trigger: .completeNGroups(n: 5),
                            action: .addWeight(kg: 5.0, lbs: 10.0)
                        )
                    ),
                ]
            ),

            // MARK: - Light
            DayDefinition(
                name: "Light",
                shortLabel: "L",
                suggestedWeekday: 4,
                exerciseSlots: [
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Bench Press",
                        alternatives: [
                            "Dumbbell Bench Press",
                            "Incline Bench Press",
                            "Floor Press",
                            "Close-Grip Bench Press",
                        ],
                        setGroups: [
                            SetGroup(
                                sets: [
                                    SetScheme(intensity: 0.50, reps: 5),
                                ],
                                repeatCount: .matchDay("Heavy")
                            ),
                        ],
                        progression: ProgressionRule(
                            trigger: .completeNGroups(n: 5),
                            action: .addWeight(kg: 2.5, lbs: 5.0)
                        )
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Deadlift",
                        alternatives: [
                            "Romanian Deadlift",
                            "Sumo Deadlift",
                            "Trap Bar Deadlift",
                        ],
                        setGroups: [
                            SetGroup(
                                sets: [
                                    SetScheme(intensity: 0.50, reps: 5),
                                ],
                                repeatCount: .matchDay("Heavy")
                            ),
                        ],
                        progression: ProgressionRule(
                            trigger: .completeNGroups(n: 5),
                            action: .addWeight(kg: 5.0, lbs: 10.0)
                        )
                    ),
                ]
            ),

            // MARK: - Medium
            DayDefinition(
                name: "Medium",
                shortLabel: "M",
                suggestedWeekday: 6,
                exerciseSlots: [
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Bench Press",
                        alternatives: [
                            "Dumbbell Bench Press",
                            "Incline Bench Press",
                            "Floor Press",
                            "Close-Grip Bench Press",
                        ],
                        setGroups: [
                            SetGroup(
                                sets: [
                                    SetScheme(intensity: 0.50, reps: 5),
                                    SetScheme(intensity: 0.75, reps: 5),
                                ],
                                repeatCount: .matchDay("Heavy")
                            ),
                        ],
                        progression: ProgressionRule(
                            trigger: .completeNGroups(n: 5),
                            action: .addWeight(kg: 2.5, lbs: 5.0)
                        )
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Deadlift",
                        alternatives: [
                            "Romanian Deadlift",
                            "Sumo Deadlift",
                            "Trap Bar Deadlift",
                        ],
                        setGroups: [
                            SetGroup(
                                sets: [
                                    SetScheme(intensity: 0.50, reps: 5),
                                    SetScheme(intensity: 0.75, reps: 5),
                                ],
                                repeatCount: .matchDay("Heavy")
                            ),
                        ],
                        progression: ProgressionRule(
                            trigger: .completeNGroups(n: 5),
                            action: .addWeight(kg: 5.0, lbs: 10.0)
                        )
                    ),
                ]
            ),
        ]
    )

    // MARK: - Shared Week Overrides

    static let delormeWeekOverrides: [WeekOverride] = [
        WeekOverride(
            week: -1,
            dayOverrides: [
                .init(dayName: "Heavy", intensities: [0.50, 0.75], groupCount: 3),
                .init(dayName: "Light", intensities: [0.50, 0.75], groupCount: 4),
                .init(dayName: "Medium", intensities: [0.50, 0.75], groupCount: 5),
            ]
        ),
        WeekOverride(
            week: 0,
            dayOverrides: [
                .init(dayName: "Heavy", intensities: [0.50, 0.75, 1.00], groupCount: 2),
                .init(dayName: "Light", intensities: [0.50, 0.75], groupCount: 7),
                .init(dayName: "Medium", intensities: [0.50, 0.75], groupCount: 5),
            ]
        ),
    ]
}
