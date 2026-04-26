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
}

// MARK: - WorkoutEngine ↔ DeLormeEngine Parity Tests

final class WorkoutEngineParityTests: XCTestCase {

    private let definition = ProgramDefinition.delormeClassic
    private let weeks = [-1, 0, 1, 2, 3, 4, 5, 6, 7]
    private let dayTypes: [DayType] = [.heavy, .light, .medium]

    // MARK: - Intensity Parity

    func testIntensityMatchesDeLormeAllWeeksAllDays() {
        for week in weeks {
            for dayType in dayTypes {
                let expected = DeLormeEngine.intensityLevels(for: dayType, week: week)
                let actual = WorkoutEngine.intensityLevels(
                    definition: definition,
                    dayName: dayType.rawValue,
                    week: week
                )
                XCTAssertEqual(
                    actual, expected,
                    "Intensity mismatch at week \(week), day \(dayType.rawValue)"
                )
            }
        }
    }

    // MARK: - Group Count Parity

    func testGroupCountMatchesDeLormeAllWeeksAllDays() {
        let mondayCountsToTest: [Int?] = [nil, 3, 5, 7]

        for week in weeks {
            for dayType in dayTypes {
                for mondayCount in mondayCountsToTest {
                    let expected = DeLormeEngine.seriesCount(
                        week: week,
                        dayType: dayType,
                        mondaySeriesCount: mondayCount
                    )
                    let actual = WorkoutEngine.groupCount(
                        definition: definition,
                        dayName: dayType.rawValue,
                        week: week,
                        heavyGroupCount: mondayCount
                    )

                    switch (expected, actual) {
                    case (.fixed(let e), .fixed(let a)):
                        XCTAssertEqual(
                            a, e,
                            "Group count mismatch at week \(week), day \(dayType.rawValue), mondayCount \(String(describing: mondayCount)): expected .fixed(\(e)), got .fixed(\(a))"
                        )
                    case (.max, .max):
                        break // match
                    default:
                        XCTFail(
                            "Group mode mismatch at week \(week), day \(dayType.rawValue), mondayCount \(String(describing: mondayCount)): expected \(expected), got \(actual)"
                        )
                    }
                }
            }
        }
    }

    // MARK: - Generated Workout Parity

    func testGeneratedWorkoutMatchesDeLorme() {
        let exercises = Exercise.defaultExercises(unit: .kg)

        let testCases: [(DayType, Int)] = [
            (.heavy, -1), (.light, -1), (.medium, -1),
            (.heavy, 0), (.light, 0), (.medium, 0),
            (.heavy, 1), (.light, 1), (.medium, 1),
            (.heavy, 4),
            (.heavy, 7),
        ]

        for (dayType, week) in testCases {
            let expected = DeLormeEngine.generateSeries(
                exercises: exercises,
                dayType: dayType,
                week: week
            )
            let actual = WorkoutEngine.generateWorkout(
                definition: definition,
                dayName: dayType.rawValue,
                week: week,
                exercises: exercises
            )

            XCTAssertEqual(
                actual.count, expected.count,
                "Exercise count mismatch at week \(week), day \(dayType.rawValue)"
            )

            for i in 0..<min(actual.count, expected.count) {
                let a = actual[i]
                let e = expected[i]
                XCTAssertEqual(a.name, e.name, "Name mismatch at exercise \(i)")
                XCTAssertEqual(a.type, e.type, "Type mismatch at exercise \(i)")
                XCTAssertEqual(a.unit, e.unit, "Unit mismatch at exercise \(i)")
                XCTAssertEqual(
                    a.sets.count, e.sets.count,
                    "Set count mismatch at exercise \(i), week \(week), day \(dayType.rawValue)"
                )

                for j in 0..<min(a.sets.count, e.sets.count) {
                    XCTAssertEqual(
                        a.sets[j].intensity, e.sets[j].intensity,
                        accuracy: 0.001,
                        "Intensity mismatch at exercise \(i), set \(j)"
                    )
                    XCTAssertEqual(
                        a.sets[j].weight, e.sets[j].weight,
                        accuracy: 0.001,
                        "Weight mismatch at exercise \(i), set \(j)"
                    )
                    XCTAssertEqual(
                        a.sets[j].reps, e.sets[j].reps,
                        "Reps mismatch at exercise \(i), set \(j)"
                    )
                    XCTAssertEqual(
                        a.sets[j].pushUpVariant, e.sets[j].pushUpVariant,
                        "PushUpVariant mismatch at exercise \(i), set \(j)"
                    )
                }
            }
        }
    }

    // MARK: - Progression Parity

    func testProgressionMatchesDeLorme() {
        let rule = ProgressionRule(
            trigger: .completeNGroups(n: 5),
            action: .addWeight(kg: 2.5, lbs: 5.0)
        )

        let histories: [[Bool]] = [
            [],
            [true],
            [false],
            [true, true, true],
            [true, false, true],
            [false, false, false],
            [true, true, true, true, true],
            [true, false, true, false, true, true],
        ]

        let initial10RM = 60.0
        let increment = 2.5

        for history in histories {
            let expected = DeLormeEngine.calculate10RM(
                initial10RM: initial10RM,
                increment: increment,
                completedFiveSeries: history
            )
            let actual = WorkoutEngine.applyProgression(
                rule: rule,
                initial10RM: initial10RM,
                unit: .kg,
                completedGroupCounts: history
            )
            XCTAssertEqual(
                actual, expected,
                accuracy: 0.001,
                "Progression mismatch for history \(history)"
            )
        }
    }

    func testProgressionMatchesDeLormeLbs() {
        let rule = ProgressionRule(
            trigger: .completeNGroups(n: 5),
            action: .addWeight(kg: 2.5, lbs: 5.0)
        )

        let histories: [[Bool]] = [
            [true],
            [true, true, true],
            [true, false, true],
        ]

        let initial10RM = 135.0
        let incrementLbs = 5.0

        for history in histories {
            let expected = DeLormeEngine.calculate10RM(
                initial10RM: initial10RM,
                increment: incrementLbs,
                completedFiveSeries: history
            )
            let actual = WorkoutEngine.applyProgression(
                rule: rule,
                initial10RM: initial10RM,
                unit: .lbs,
                completedGroupCounts: history
            )
            XCTAssertEqual(
                actual, expected,
                accuracy: 0.001,
                "Progression mismatch (lbs) for history \(history)"
            )
        }
    }

    // MARK: - Suggested Day Parity

    func testSuggestedDayMatchesDeLorme() {
        for dayType in dayTypes {
            let expected = DeLormeEngine.suggestedDay(for: dayType)
            let actual = WorkoutEngine.suggestedDay(
                definition: definition,
                dayName: dayType.rawValue
            )
            XCTAssertEqual(
                actual, expected,
                "Suggested day mismatch for \(dayType.rawValue)"
            )
        }
    }

    // MARK: - Current Week Parity

    func testCurrentWeekMatchesDeLorme() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 6))!

        for weeksElapsed in [0, 1, 2, 3, 5, 8, 10, 15] {
            let currentDate = calendar.date(byAdding: .weekOfYear, value: weeksElapsed, to: startDate)!
            let expected = DeLormeEngine.currentWeek(
                startDate: startDate,
                currentDate: currentDate,
                introCycleEnabled: true
            )
            let actual = WorkoutEngine.currentWeek(
                startDate: startDate,
                currentDate: currentDate,
                definition: definition
            )
            XCTAssertEqual(
                actual, expected,
                "Current week mismatch at \(weeksElapsed) weeks elapsed"
            )
        }
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
