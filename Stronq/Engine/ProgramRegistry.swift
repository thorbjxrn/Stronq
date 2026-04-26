import Foundation

struct ProgramRegistry {
    static let all: [ProgramDefinition] = [
        .delormeClassic,
        .delormeYoked,
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
        default: return (40, 90, 2.5, 5)
        }
    }
}
