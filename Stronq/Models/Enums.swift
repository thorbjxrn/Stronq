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

    static func sortOrder(_ rawValue: String) -> Int {
        switch rawValue {
        case "Heavy": 0
        case "Light": 1
        case "Medium": 2
        default: 3
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
    case oneArmOneLeg = "One Arm One Leg"

    var shortName: String {
        switch self {
        case .kneeling: "Kneel"
        case .regular: "  Reg"
        case .diamond: " Diam"
        case .archer: " Arch"
        case .oneArm: "1-Arm"
        case .oneArmOneLeg: "1A1Lg"
        }
    }

    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }

    static let selectableMaxLevels: [(variant: PushUpVariant, label: String)] = [
        (.diamond, "Beginner"),
        (.archer, "Intermediate"),
        (.oneArm, "Advanced"),
        (.oneArmOneLeg, "Expert"),
    ]

    static func forIntensity(_ intensity: Double, maxLevel: PushUpVariant) -> PushUpVariant {
        let maxIdx = maxLevel.index
        let offset: Int
        switch intensity {
        case 0.75: offset = 1
        case 1.0: offset = 0
        default: offset = 2
        }
        let target = max(maxIdx - offset, 0)
        return allCases[target]
    }

    static func progressionLabel(for maxLevel: PushUpVariant) -> String {
        let levels = [
            forIntensity(0.5, maxLevel: maxLevel),
            forIntensity(0.75, maxLevel: maxLevel),
            forIntensity(1.0, maxLevel: maxLevel)
        ]
        return levels.map(\.rawValue).joined(separator: " → ")
    }
}
