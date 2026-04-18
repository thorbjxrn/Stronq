import Foundation

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
        if formatted.hasSuffix("00") {
            return String(format: "%.0f", weight)
        }
        if formatted.hasSuffix("0") {
            return String(format: "%.1f", weight)
        }
        return formatted
    }
}
