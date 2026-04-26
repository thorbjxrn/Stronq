import Foundation

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
