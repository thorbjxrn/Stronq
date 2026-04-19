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

enum PushUpVariant: String, Codable, CaseIterable {
    case kneeling = "Kneeling"
    case regular = "Regular"
    case diamond = "Diamond"
    case archer = "Archer"
    case oneArm = "One Arm"

    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }

    static func forIntensity(_ intensity: Double, startingLevel: PushUpVariant) -> PushUpVariant {
        let start = startingLevel.index
        let offset: Int
        switch intensity {
        case 0.75: offset = 1
        case 1.0: offset = 2
        default: offset = 0
        }
        let target = min(start + offset, allCases.count - 1)
        return allCases[target]
    }

    static func progressionLabel(from start: PushUpVariant) -> String {
        let levels = (0...2).map { offset in
            let idx = min(start.index + offset, allCases.count - 1)
            return allCases[idx].rawValue
        }
        return levels.joined(separator: " → ")
    }
}
