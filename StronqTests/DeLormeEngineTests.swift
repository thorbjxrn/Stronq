import XCTest
@testable import Stronq

final class DeLormeEngineTests: XCTestCase {

    // MARK: - Intensity Levels

    func testHeavyDayThreeIntensityLevels() {
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .heavy, week: 1), [0.5, 0.75, 1.0])
    }

    func testMediumDayTwoIntensityLevels() {
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .medium, week: 1), [0.5, 0.75])
    }

    func testLightDayOneIntensityLevel() {
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .light, week: 1), [0.5])
    }

    func testIntroWeek1AllDaysTwoLevels() {
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .heavy, week: -1), [0.5, 0.75])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .light, week: -1), [0.5, 0.75])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .medium, week: -1), [0.5, 0.75])
    }

    func testIntroWeek2HeavyAdds100Percent() {
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .heavy, week: 0), [0.5, 0.75, 1.0])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .light, week: 0), [0.5, 0.75])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .medium, week: 0), [0.5, 0.75])
    }

    // MARK: - Weight Calculation (all days use same 10RM)

    func testWeightsFromTenRM() {
        XCTAssertEqual(DeLormeEngine.calculateWeight(tenRM: 200, intensity: 0.5), 100)
        XCTAssertEqual(DeLormeEngine.calculateWeight(tenRM: 200, intensity: 0.75), 150)
        XCTAssertEqual(DeLormeEngine.calculateWeight(tenRM: 200, intensity: 1.0), 200)
    }

    // MARK: - 10RM Progression

    func testProgressionAddsWeightAfterFiveSeries() {
        // Initial 10RM = 200, increment = 10
        // Week 1: completed 5 series -> add weight
        // Week 2: completed 4 series -> no add
        // Week 3: completed 5 series -> add weight
        let history = [true, false, true]
        let rm = DeLormeEngine.calculate10RM(initial10RM: 200, increment: 10, completedFiveSeries: history)
        XCTAssertEqual(rm, 220) // 200 + 10 + 0 + 10
    }

    func testNoProgressionUntilFiveSeries() {
        let history = [false, false, false]
        let rm = DeLormeEngine.calculate10RM(initial10RM: 200, increment: 10, completedFiveSeries: history)
        XCTAssertEqual(rm, 200)
    }

    // MARK: - Series Mode

    func testHeavyDayIsMaxSeries() {
        let mode = DeLormeEngine.seriesCount(week: 1, dayType: .heavy, mondaySeriesCount: nil)
        XCTAssertEqual(mode, .max)
    }

    func testLightDayUsesMonday() {
        let mode = DeLormeEngine.seriesCount(week: 1, dayType: .light, mondaySeriesCount: 4)
        XCTAssertEqual(mode, .fixed(4))
    }

    func testMediumDayUsesMonday() {
        let mode = DeLormeEngine.seriesCount(week: 1, dayType: .medium, mondaySeriesCount: 4)
        XCTAssertEqual(mode, .fixed(4))
    }

    func testIntroWeek1FixedSeries() {
        XCTAssertEqual(DeLormeEngine.seriesCount(week: -1, dayType: .heavy, mondaySeriesCount: nil), .fixed(3))
        XCTAssertEqual(DeLormeEngine.seriesCount(week: -1, dayType: .light, mondaySeriesCount: nil), .fixed(4))
        XCTAssertEqual(DeLormeEngine.seriesCount(week: -1, dayType: .medium, mondaySeriesCount: nil), .fixed(5))
    }

    func testIntroWeek2FixedSeries() {
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 0, dayType: .heavy, mondaySeriesCount: nil), .fixed(2))
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 0, dayType: .light, mondaySeriesCount: nil), .fixed(7))
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 0, dayType: .medium, mondaySeriesCount: nil), .fixed(5))
    }

    // MARK: - Workout Generation

    func testGeneratesCorrectSetsForHeavyDay() {
        let exercises = Exercise.defaultExercises()
        let planned = DeLormeEngine.generateSeries(exercises: exercises, dayType: .heavy, week: 1)

        // Each exercise should have 3 sets (50%, 75%, 100%)
        for ex in planned {
            XCTAssertEqual(ex.sets.count, 3)
            XCTAssertEqual(ex.sets[0].intensity, 0.5)
            XCTAssertEqual(ex.sets[1].intensity, 0.75)
            XCTAssertEqual(ex.sets[2].intensity, 1.0)
        }
    }

    func testGeneratesCorrectSetsForLightDay() {
        let exercises = Exercise.defaultExercises()
        let planned = DeLormeEngine.generateSeries(exercises: exercises, dayType: .light, week: 1)

        for ex in planned {
            XCTAssertEqual(ex.sets.count, 1)
            XCTAssertEqual(ex.sets[0].intensity, 0.5)
        }
    }

    func testGeneratesCorrectSetsForMediumDay() {
        let exercises = Exercise.defaultExercises()
        let planned = DeLormeEngine.generateSeries(exercises: exercises, dayType: .medium, week: 1)

        for ex in planned {
            XCTAssertEqual(ex.sets.count, 2)
            XCTAssertEqual(ex.sets[0].intensity, 0.5)
            XCTAssertEqual(ex.sets[1].intensity, 0.75)
        }
    }
}
