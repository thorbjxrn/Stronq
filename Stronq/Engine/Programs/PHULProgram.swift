import Foundation

extension ProgramDefinition {
    static let phul = ProgramDefinition(
        id: "phul",
        name: "PHUL",
        description: "Power Hypertrophy Upper Lower — 4 day split",
        isPremium: true,
        cycleLength: nil,
        repeating: true,
        introCycle: nil,
        days: [
            // MARK: - Upper Power
            DayDefinition(
                name: "Upper Power",
                shortLabel: "UP",
                suggestedWeekday: 2,
                exerciseSlots: [
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Bench Press",
                        alternatives: ["Dumbbell Bench Press", "Incline Bench Press"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 1.0, reps: 5)], repeatCount: .fixed(4))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Barbell Row",
                        alternatives: ["Dumbbell Row", "Seated Cable Row"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 1.0, reps: 5)], repeatCount: .fixed(4))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Overhead Press",
                        alternatives: ["Dumbbell Shoulder Press"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.85, reps: 8)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Barbell Curl",
                        alternatives: ["Dumbbell Curl", "Hammer Curl"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.8, reps: 10)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .isolation,
                        defaultExercise: "Tricep Pushdown",
                        alternatives: ["Skull Crusher", "Overhead Extension"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.8, reps: 10)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                ]
            ),

            // MARK: - Lower Power
            DayDefinition(
                name: "Lower Power",
                shortLabel: "LP",
                suggestedWeekday: 3,
                exerciseSlots: [
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Back Squat",
                        alternatives: ["Front Squat", "Goblet Squat"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 1.0, reps: 5)], repeatCount: .fixed(4))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 5.0, lbs: 10.0))
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Deadlift",
                        alternatives: ["Romanian Deadlift", "Sumo Deadlift"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 1.0, reps: 5)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 5.0, lbs: 10.0))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Leg Press",
                        alternatives: ["Hack Squat"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.85, reps: 8)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 5.0, lbs: 10.0))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Leg Curl",
                        alternatives: ["Romanian Deadlift"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.8, reps: 10)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .isolation,
                        defaultExercise: "Calf Raise",
                        alternatives: ["Seated Calf Raise"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.8, reps: 12)], repeatCount: .fixed(4))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 5.0, lbs: 10.0))
                    ),
                ]
            ),

            // MARK: - Upper Hypertrophy
            DayDefinition(
                name: "Upper Hypertrophy",
                shortLabel: "UH",
                suggestedWeekday: 5,
                exerciseSlots: [
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Incline Bench Press",
                        alternatives: ["Incline Dumbbell Press"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.85, reps: 10)], repeatCount: .fixed(4))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Lat Pulldown",
                        alternatives: ["Pull-up", "Chin-up"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.85, reps: 10)], repeatCount: .fixed(4))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Dumbbell Lateral Raise",
                        alternatives: ["Cable Lateral Raise"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.75, reps: 12)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 1.0, lbs: 2.5))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Incline Dumbbell Curl",
                        alternatives: ["Preacher Curl"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.75, reps: 12)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 1.0, lbs: 2.5))
                    ),
                    ExerciseSlot(
                        role: .isolation,
                        defaultExercise: "Overhead Tricep Extension",
                        alternatives: ["Tricep Kickback"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.75, reps: 12)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 1.0, lbs: 2.5))
                    ),
                ]
            ),

            // MARK: - Lower Hypertrophy
            DayDefinition(
                name: "Lower Hypertrophy",
                shortLabel: "LH",
                suggestedWeekday: 6,
                exerciseSlots: [
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Front Squat",
                        alternatives: ["Goblet Squat", "Leg Press"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.85, reps: 10)], repeatCount: .fixed(4))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 5.0, lbs: 10.0))
                    ),
                    ExerciseSlot(
                        role: .primary,
                        defaultExercise: "Romanian Deadlift",
                        alternatives: ["Stiff-Leg Deadlift"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.85, reps: 10)], repeatCount: .fixed(4))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Leg Extension",
                        alternatives: ["Bulgarian Split Squat"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.8, reps: 12)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .accessory,
                        defaultExercise: "Leg Curl",
                        alternatives: ["Glute Ham Raise"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.8, reps: 12)], repeatCount: .fixed(3))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 2.5, lbs: 5.0))
                    ),
                    ExerciseSlot(
                        role: .isolation,
                        defaultExercise: "Seated Calf Raise",
                        alternatives: ["Standing Calf Raise"],
                        setGroups: [SetGroup(sets: [SetScheme(intensity: 0.8, reps: 15)], repeatCount: .fixed(4))],
                        progression: ProgressionRule(trigger: .completeAllSets, action: .addWeight(kg: 5.0, lbs: 10.0))
                    ),
                ]
            ),
        ]
    )
}
