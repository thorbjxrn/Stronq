import Foundation

extension ProgramDefinition {

    static let delormeYoked = ProgramDefinition(
        id: "yoked",
        name: "DeLorme Yoked",
        description: "Push-up + Zercher Squat + Half-Kneeling Pulldown",
        isPremium: true,
        cycleLength: 7,
        repeating: false,
        introCycle: IntroCycle(weeks: 2, volumeMultiplier: 1.0),
        introOverrides: Self.delormeIntroOverrides,
        days: [
            // MARK: - Heavy
            DayDefinition(
                name: "Heavy",
                shortLabel: "H",
                suggestedWeekday: 2,
                exerciseSlots: [
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Push-up",
                        alternatives: [
                            "Dips",
                            "Dumbbell Bench Press",
                            "Bench Press",
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
                            action: .addWeight(kg: 0, lbs: 0)
                        )
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Zercher Squat",
                        alternatives: [
                            "Back Squat",
                            "Front Squat",
                            "Goblet Squat",
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
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Half-Kneeling Pulldown",
                        alternatives: [
                            "Seated Cable Row",
                            "Dumbbell Row",
                            "Barbell Row",
                            "Lat Pulldown",
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
                        defaultExercise: "Push-up",
                        alternatives: [
                            "Dips",
                            "Dumbbell Bench Press",
                            "Bench Press",
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
                            action: .addWeight(kg: 0, lbs: 0)
                        )
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Zercher Squat",
                        alternatives: [
                            "Back Squat",
                            "Front Squat",
                            "Goblet Squat",
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
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Half-Kneeling Pulldown",
                        alternatives: [
                            "Seated Cable Row",
                            "Dumbbell Row",
                            "Barbell Row",
                            "Lat Pulldown",
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
                        defaultExercise: "Push-up",
                        alternatives: [
                            "Dips",
                            "Dumbbell Bench Press",
                            "Bench Press",
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
                            action: .addWeight(kg: 0, lbs: 0)
                        )
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Zercher Squat",
                        alternatives: [
                            "Back Squat",
                            "Front Squat",
                            "Goblet Squat",
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
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Half-Kneeling Pulldown",
                        alternatives: [
                            "Seated Cable Row",
                            "Dumbbell Row",
                            "Barbell Row",
                            "Lat Pulldown",
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
                ]
            ),
        ]
    )
}
