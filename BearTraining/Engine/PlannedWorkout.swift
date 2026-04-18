import Foundation

struct PlannedWorkout {
    let week: Int
    let dayType: DayType
    let exercises: [PlannedExercise]
}

struct PlannedExercise {
    let name: String
    let type: ExerciseType
    let sets: [PlannedSet]
    let seriesCount: Int
    let unit: WeightUnit

    var totalSets: Int { sets.count * seriesCount }
}

struct PlannedSet {
    let intensity: Double
    let weight: Double
    let reps: Int
    let pushUpVariant: PushUpVariant?

    var intensityLabel: String {
        switch intensity {
        case 0.5: "50%"
        case 0.75: "75%"
        case 1.0: "100%"
        default: "\(Int(intensity * 100))%"
        }
    }

    var displayWeight: String {
        if let variant = pushUpVariant {
            return variant.rawValue
        }
        let formatted = String(format: "%.2f", weight)
        if formatted.hasSuffix("0") {
            let trimmed = String(format: "%.1f", weight)
            return trimmed.hasSuffix(".0") ? String(format: "%.0f", weight) : trimmed
        }
        return formatted
    }
}
