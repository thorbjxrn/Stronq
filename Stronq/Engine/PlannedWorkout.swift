import Foundation

struct PlannedSet: Sendable {
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

    var shortDisplayWeight: String {
        if let variant = pushUpVariant {
            return variant.shortName
        }
        return String(format: "%.2f", weight)
    }

    var displayWeight: String {
        if let variant = pushUpVariant {
            return variant.rawValue
        }
        return String(format: "%.2f", weight)
    }
}
