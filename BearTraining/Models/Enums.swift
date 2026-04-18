import Foundation

enum DayType: String, Codable, CaseIterable {
    case heavy = "Heavy"
    case light = "Light"
    case medium = "Medium"

    var intensityLevels: [Double] {
        switch self {
        case .heavy: [0.5, 0.75, 1.0]
        case .medium: [0.5, 0.75]
        case .light: [0.5]
        }
    }

    var setsPerSeries: Int { intensityLevels.count }

    var weekday: Int {
        switch self {
        case .heavy: 2   // Monday
        case .light: 4   // Wednesday
        case .medium: 6  // Friday
        }
    }

    var shortLabel: String {
        switch self {
        case .heavy: "H"
        case .light: "L"
        case .medium: "M"
        }
    }
}

enum ExerciseType: String, Codable {
    case bodyweight
    case weighted
}

enum WeightUnit: String, Codable, CaseIterable {
    case kg
    case lbs

    var symbol: String { rawValue }
}

enum PushUpVariant: String, Codable {
    case regular = "Regular"
    case archer = "Archer"
    case oneArm = "One Arm"

    static func from(intensity: Double) -> PushUpVariant {
        switch intensity {
        case 0.75: .archer
        case 1.0: .oneArm
        default: .regular
        }
    }
}
