import XCTest
@testable import Stronq

final class ProgramDefinitionTests: XCTestCase {

    func testRepeatModeFixed() {
        let mode = RepeatMode.fixed(4)
        if case .fixed(let n) = mode {
            XCTAssertEqual(n, 4)
        } else {
            XCTFail("Expected .fixed")
        }
    }

    func testRepeatModeMax() {
        let mode = RepeatMode.max
        XCTAssertEqual(mode, .max)
    }

    func testRepeatModeMatchDay() {
        let mode = RepeatMode.matchDay("Heavy")
        if case .matchDay(let name) = mode {
            XCTAssertEqual(name, "Heavy")
        } else {
            XCTFail("Expected .matchDay")
        }
    }

    func testProgressionRuleCompleteNGroups() {
        let rule = ProgressionRule(
            trigger: .completeNGroups(n: 5),
            action: .addWeight(kg: 2.5, lbs: 5.0)
        )
        if case .completeNGroups(let n) = rule.trigger {
            XCTAssertEqual(n, 5)
        } else {
            XCTFail("Expected .completeNGroups")
        }
        if case .addWeight(let kg, let lbs) = rule.action {
            XCTAssertEqual(kg, 2.5)
            XCTAssertEqual(lbs, 5.0)
        } else {
            XCTFail("Expected .addWeight")
        }
    }

    func testProgramDefinitionCodable() throws {
        let definition = ProgramDefinition(
            id: "test",
            name: "Test Program",
            description: "A test",
            isPremium: false,
            cycleLength: 4,
            repeating: false,
            introCycle: nil,
            days: [
                DayDefinition(
                    name: "Day A",
                    shortLabel: "A",
                    suggestedWeekday: 2,
                    exerciseSlots: []
                )
            ]
        )

        let data = try JSONEncoder().encode(definition)
        let decoded = try JSONDecoder().decode(ProgramDefinition.self, from: data)
        XCTAssertEqual(decoded.id, "test")
        XCTAssertEqual(decoded.name, "Test Program")
        XCTAssertEqual(decoded.days.count, 1)
        XCTAssertEqual(decoded.days[0].shortLabel, "A")
    }

    func testDayIndexAndSortOrder() {
        let definition = ProgramDefinition(
            id: "test", name: "Test", description: "", isPremium: false,
            days: [
                DayDefinition(name: "Heavy", shortLabel: "H", exerciseSlots: []),
                DayDefinition(name: "Light", shortLabel: "L", exerciseSlots: []),
                DayDefinition(name: "Medium", shortLabel: "M", exerciseSlots: []),
            ]
        )
        XCTAssertEqual(definition.dayIndex(for: "Heavy"), 0)
        XCTAssertEqual(definition.dayIndex(for: "Light"), 1)
        XCTAssertEqual(definition.dayIndex(for: "Medium"), 2)
        XCTAssertNil(definition.dayIndex(for: "Unknown"))
        XCTAssertEqual(definition.sortOrder(for: "Heavy"), 0)
        XCTAssertEqual(definition.sortOrder(for: "Unknown"), 3)
    }


    // MARK: - Program Registry

    func testRegistryFindsClassic() {
        let def = ProgramRegistry.definition(for: "classic")
        XCTAssertNotNil(def)
        XCTAssertEqual(def?.name, "DeLorme Classic")
    }

    func testRegistryFindsYoked() {
        let def = ProgramRegistry.definition(for: "yoked")
        XCTAssertNotNil(def)
        XCTAssertEqual(def?.name, "DeLorme Yoked")
    }

    func testRegistryReturnsNilForUnknown() {
        let def = ProgramRegistry.definition(for: "nonexistent")
        XCTAssertNil(def)
    }

    func testRegistryContainsAllPrograms() {
        XCTAssertEqual(ProgramRegistry.all.count, 2)
    }
}
