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

    func testRegistryFindsPHUL() {
        let def = ProgramRegistry.definition(for: "phul")
        XCTAssertNotNil(def)
        XCTAssertEqual(def?.name, "PHUL")
    }
}

final class PHULTests: XCTestCase {

    let definition = ProgramDefinition.phul

    func testPHULHasFourDays() {
        XCTAssertEqual(definition.days.count, 4)
        XCTAssertEqual(definition.days.map(\.name), ["Upper Power", "Lower Power", "Upper Hypertrophy", "Lower Hypertrophy"])
        XCTAssertEqual(definition.days.map(\.shortLabel), ["UP", "LP", "UH", "LH"])
    }

    func testPHULIsRepeating() {
        XCTAssertTrue(definition.repeating)
        XCTAssertNil(definition.cycleLength)
    }

    func testPHULIsPremium() {
        XCTAssertTrue(definition.isPremium)
    }

    func testUpperPowerExercises() {
        let day = definition.days[0]
        XCTAssertGreaterThanOrEqual(day.exerciseSlots.count, 5)
        XCTAssertEqual(day.exerciseSlots[0].defaultExercise, "Bench Press")
        XCTAssertEqual(day.exerciseSlots[0].role, .primary)
        XCTAssertEqual(day.exerciseSlots[1].defaultExercise, "Barbell Row")
        XCTAssertEqual(day.exerciseSlots[1].role, .primary)
    }

    func testPowerDaysStraightSets() {
        let upperPower = definition.days[0]
        for slot in upperPower.exerciseSlots where slot.role == .primary {
            let group = slot.setGroups[0]
            if case .fixed(let n) = group.repeatCount {
                XCTAssertGreaterThanOrEqual(n, 3)
                XCTAssertLessThanOrEqual(n, 5)
            } else {
                XCTFail("Primary power exercises should use .fixed repeat count")
            }
        }
    }

    func testHypertrophyDaysHigherReps() {
        let upperHypertrophy = definition.days[2]
        for slot in upperHypertrophy.exerciseSlots {
            let reps = slot.setGroups[0].sets[0].reps
            XCTAssertGreaterThanOrEqual(reps, 8, "\(slot.defaultExercise) should have 8+ reps on hypertrophy day")
        }
    }

    func testProgressionTriggersCompleteAllSets() {
        for day in definition.days {
            for slot in day.exerciseSlots {
                XCTAssertEqual(slot.progression.trigger, .completeAllSets)
            }
        }
    }

    func testRepeatingCycleLoopsBack() {
        let sessions = definition.days.map { (dayName: $0.name, week: 1, isCompleted: true) }
        let next = WorkoutEngine.nextDay(definition: definition, currentWeek: 1, completedSessions: sessions)
        XCTAssertNotNil(next)
        XCTAssertEqual(next?.dayName, "Upper Power")
    }

    func testWorkoutGeneration() {
        let exercises = [
            Exercise(name: "Bench Press", type: .weighted, initial10RM: 80, weightIncrement: 2.5, unit: .kg, sortOrder: 0),
            Exercise(name: "Barbell Row", type: .weighted, initial10RM: 60, weightIncrement: 2.5, unit: .kg, sortOrder: 1),
        ]

        let planned = WorkoutEngine.generateWorkout(
            definition: definition,
            dayName: "Upper Power",
            week: 1,
            exercises: exercises
        )
        XCTAssertEqual(planned.count, 2)
        XCTAssertEqual(planned[0].sets[0].weight, 80)
    }
}
