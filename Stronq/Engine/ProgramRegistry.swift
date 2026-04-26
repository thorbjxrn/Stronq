import Foundation

struct ProgramRegistry {
    static let all: [ProgramDefinition] = [
        .delormeClassic,
        .delormeYoked,
        .candito6Week,
    ]

    static func definition(for programType: String) -> ProgramDefinition? {
        all.first { $0.id == programType }
    }
}

struct ExerciseDefaults {
    let name: String
    let type: ExerciseType
    let defaultRM: Double
    let defaultRMLbs: Double
    let increment: Double
    let incrementLbs: Double

    static func defaults(for definition: ProgramDefinition) -> [ExerciseDefaults] {
        var seen = Set<String>()
        var result: [ExerciseDefaults] = []
        for day in definition.days {
            for slot in day.exerciseSlots {
                guard !seen.contains(slot.defaultExercise) else { continue }
                seen.insert(slot.defaultExercise)
                let (kg, lbs, incKg, incLbs) = defaultWeights(for: slot.defaultExercise)
                result.append(ExerciseDefaults(
                    name: slot.defaultExercise,
                    type: slot.defaultExercise == "Push-up" ? .bodyweight : .weighted,
                    defaultRM: kg,
                    defaultRMLbs: lbs,
                    increment: incKg,
                    incrementLbs: incLbs
                ))
            }
        }
        return result
    }

    private static func defaultWeights(for exercise: String) -> (kg: Double, lbs: Double, incKg: Double, incLbs: Double) {
        switch exercise {
        case "Bench Press": return (60, 135, 2.5, 5)
        case "Deadlift": return (80, 175, 5, 10)
        case "Zercher Squat": return (45, 95, 5, 10)
        case "Half-Kneeling Pulldown": return (25, 55, 2.5, 5)
        case "Push-up": return (0, 0, 0, 0)
        case "Barbell Row": return (50, 110, 2.5, 5)
        case "Overhead Press": return (35, 75, 2.5, 5)
        case "Back Squat": return (60, 135, 5, 10)
        case "Front Squat": return (50, 110, 5, 10)
        case "Barbell Curl": return (25, 55, 2.5, 5)
        case "Tricep Pushdown": return (20, 45, 2.5, 5)
        case "Leg Press": return (100, 220, 5, 10)
        case "Leg Curl": return (30, 65, 2.5, 5)
        case "Calf Raise": return (40, 90, 5, 10)
        case "Incline Bench Press": return (50, 110, 2.5, 5)
        case "Lat Pulldown": return (40, 90, 2.5, 5)
        case "Dumbbell Lateral Raise": return (8, 15, 1, 2.5)
        case "Incline Dumbbell Curl": return (10, 20, 1, 2.5)
        case "Overhead Tricep Extension": return (15, 30, 2.5, 5)
        case "Romanian Deadlift": return (60, 135, 2.5, 5)
        case "Leg Extension": return (30, 65, 2.5, 5)
        case "Seated Calf Raise": return (30, 65, 5, 10)
        default: return (40, 90, 2.5, 5)
        }
    }
}
