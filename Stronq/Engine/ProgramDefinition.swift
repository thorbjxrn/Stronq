import Foundation

enum ExerciseRole: String, Codable, Sendable {
    case primary
    case accessory
    case isolation
}

enum RepeatMode: Codable, Equatable, Sendable {
    case fixed(Int)
    case max
    case matchDay(String)
}

enum ProgressionTrigger: Codable, Equatable, Sendable {
    case completeAllSets
    case completeNGroups(n: Int)
    case amrapThreshold(reps: Int)
    case manual
}

enum ProgressionAction: Codable, Equatable, Sendable {
    case addWeight(kg: Double, lbs: Double)
    case percentageIncrease(Double)
}

struct ProgressionRule: Codable, Sendable {
    let trigger: ProgressionTrigger
    let action: ProgressionAction
}

struct SetScheme: Codable, Sendable {
    let intensity: Double
    let reps: Int
    var isAMRAP: Bool = false
    var rpe: Double? = nil
}

struct SetGroup: Codable, Sendable {
    let sets: [SetScheme]
    let repeatCount: RepeatMode
    var restBetweenSets: Int? = nil
    var restAfterGroup: Int? = nil
}

struct ExerciseSlot: Codable, Sendable {
    let role: ExerciseRole
    let defaultExercise: String
    var alternatives: [String] = []
    var muscleGroup: String? = nil
    let setGroups: [SetGroup]
    let progression: ProgressionRule
}

struct DayDefinition: Codable, Sendable {
    let name: String
    let shortLabel: String
    var suggestedWeekday: Int? = nil
    let exerciseSlots: [ExerciseSlot]
}

struct IntroCycle: Codable, Sendable {
    let weeks: Int
    let volumeMultiplier: Double
}

struct WeekOverride: Codable, Sendable {
    let week: Int
    let dayOverrides: [DayOverride]

    struct DayOverride: Codable, Sendable {
        let dayName: String
        let intensities: [Double]
        let groupCount: Int
        var reps: Int = 5
    }
}

struct ProgramDefinition: Codable, Sendable {
    let id: String
    let name: String
    let description: String
    let isPremium: Bool
    var cycleLength: Int? = nil
    var repeating: Bool = false
    var introCycle: IntroCycle? = nil
    var weekOverrides: [WeekOverride]? = nil
    let days: [DayDefinition]

    func dayIndex(for dayName: String) -> Int? {
        days.firstIndex { $0.name == dayName }
    }

    func sortOrder(for dayName: String) -> Int {
        dayIndex(for: dayName) ?? days.count
    }
}
