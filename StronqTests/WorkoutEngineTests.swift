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
        XCTAssertEqual(ProgramRegistry.all.count, 3)
    }

    func testRegistryFindsCandito() {
        let def = ProgramRegistry.definition(for: "candito-6week")
        XCTAssertNotNil(def)
        XCTAssertEqual(def?.name, "Candito 6-Week")
    }
}

final class Candito6WeekTests: XCTestCase {

    let definition = ProgramDefinition.candito6Week

    func testHasTwoDays() {
        XCTAssertEqual(definition.days.count, 2)
        XCTAssertEqual(definition.days.map(\.name), ["Upper", "Lower"])
        XCTAssertEqual(definition.days.map(\.shortLabel), ["U", "L"])
    }

    func testSixWeekNonRepeating() {
        XCTAssertEqual(definition.cycleLength, 6)
        XCTAssertFalse(definition.repeating)
    }

    func testIsPremium() {
        XCTAssertTrue(definition.isPremium)
    }

    func testConditioningWeeksHighReps() {
        let reps1 = WorkoutEngine.repCount(definition: definition, dayName: "Upper", week: 1)
        let reps2 = WorkoutEngine.repCount(definition: definition, dayName: "Lower", week: 2)
        XCTAssertEqual(reps1, 10)
        XCTAssertEqual(reps2, 10)
    }

    func testLinearProgressionWeeks() {
        let reps3 = WorkoutEngine.repCount(definition: definition, dayName: "Upper", week: 3)
        let reps4 = WorkoutEngine.repCount(definition: definition, dayName: "Lower", week: 4)
        XCTAssertEqual(reps3, 6)
        XCTAssertEqual(reps4, 6)
    }

    func testStrengthWeekLowReps() {
        let reps = WorkoutEngine.repCount(definition: definition, dayName: "Upper", week: 5)
        XCTAssertEqual(reps, 3)
    }

    func testPeakWeekSingles() {
        let reps = WorkoutEngine.repCount(definition: definition, dayName: "Lower", week: 6)
        XCTAssertEqual(reps, 1)
    }

    func testIntensityProgression() {
        let w1 = WorkoutEngine.intensityLevels(definition: definition, dayName: "Upper", week: 1)
        let w5 = WorkoutEngine.intensityLevels(definition: definition, dayName: "Upper", week: 5)
        let w6 = WorkoutEngine.intensityLevels(definition: definition, dayName: "Upper", week: 6)
        XCTAssertEqual(w1, [0.70])
        XCTAssertEqual(w5, [0.90])
        XCTAssertEqual(w6, [0.97])
    }

    func testWorkoutGenerationUsesWeekReps() {
        let exercises = [
            Exercise(name: "Bench Press", type: .weighted, initial10RM: 100, weightIncrement: 2.5, unit: .kg, sortOrder: 0),
        ]
        let w1 = WorkoutEngine.generateWorkout(definition: definition, dayName: "Upper", week: 1, exercises: exercises)
        let w6 = WorkoutEngine.generateWorkout(definition: definition, dayName: "Upper", week: 6, exercises: exercises)

        XCTAssertEqual(w1[0].sets[0].reps, 10)
        XCTAssertEqual(w1[0].sets[0].weight, 70)

        XCTAssertEqual(w6[0].sets[0].reps, 1)
        XCTAssertEqual(w6[0].sets[0].weight, 97)
    }

    func testCycleEndsAfterWeek6() {
        let sessions = (1...6).flatMap { week in
            definition.days.map { (dayName: $0.name, week: week, isCompleted: true) }
        }
        let next = WorkoutEngine.nextDay(definition: definition, currentWeek: 6, completedSessions: sessions)
        XCTAssertNil(next)
    }
}
