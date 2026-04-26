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
