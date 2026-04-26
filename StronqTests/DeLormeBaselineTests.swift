import XCTest
@testable import Stronq

final class DeLormeBaselineTests: XCTestCase {

    func testIntensityLevelsAllWeeksAllDays() {
        // Intro week 1: all days get [0.5, 0.75]
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .heavy, week: -1), [0.5, 0.75])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .light, week: -1), [0.5, 0.75])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .medium, week: -1), [0.5, 0.75])

        // Intro week 2: heavy gets 100%, others stay at 2
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .heavy, week: 0), [0.5, 0.75, 1.0])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .light, week: 0), [0.5, 0.75])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .medium, week: 0), [0.5, 0.75])

        // Normal weeks: standard pattern
        for week in 1...7 {
            XCTAssertEqual(DeLormeEngine.intensityLevels(for: .heavy, week: week), [0.5, 0.75, 1.0])
            XCTAssertEqual(DeLormeEngine.intensityLevels(for: .light, week: week), [0.5])
            XCTAssertEqual(DeLormeEngine.intensityLevels(for: .medium, week: week), [0.5, 0.75])
        }
    }

    func testSeriesCountAllWeeksAllDays() {
        // Intro week 1
        XCTAssertEqual(DeLormeEngine.seriesCount(week: -1, dayType: .heavy, mondaySeriesCount: nil), .fixed(3))
        XCTAssertEqual(DeLormeEngine.seriesCount(week: -1, dayType: .light, mondaySeriesCount: nil), .fixed(4))
        XCTAssertEqual(DeLormeEngine.seriesCount(week: -1, dayType: .medium, mondaySeriesCount: nil), .fixed(5))

        // Intro week 2
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 0, dayType: .heavy, mondaySeriesCount: nil), .fixed(2))
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 0, dayType: .light, mondaySeriesCount: nil), .fixed(7))
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 0, dayType: .medium, mondaySeriesCount: nil), .fixed(5))

        // Normal weeks
        for week in 1...7 {
            XCTAssertEqual(DeLormeEngine.seriesCount(week: week, dayType: .heavy, mondaySeriesCount: nil), .max)
            XCTAssertEqual(DeLormeEngine.seriesCount(week: week, dayType: .light, mondaySeriesCount: 4), .fixed(4))
            XCTAssertEqual(DeLormeEngine.seriesCount(week: week, dayType: .medium, mondaySeriesCount: 6), .fixed(6))
        }

        // Default to 5 when no monday data
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 3, dayType: .light, mondaySeriesCount: nil), .fixed(5))
    }

    func testWeightCalculationPrecision() {
        XCTAssertEqual(DeLormeEngine.calculateWeight(tenRM: 60, intensity: 0.5), 30)
        XCTAssertEqual(DeLormeEngine.calculateWeight(tenRM: 60, intensity: 0.75), 45)
        XCTAssertEqual(DeLormeEngine.calculateWeight(tenRM: 60, intensity: 1.0), 60)
        XCTAssertEqual(DeLormeEngine.calculateWeight(tenRM: 80, intensity: 0.5), 40)
        XCTAssertEqual(DeLormeEngine.calculateWeight(tenRM: 80, intensity: 0.75), 60)
        XCTAssertEqual(DeLormeEngine.calculateWeight(tenRM: 80, intensity: 1.0), 80)
    }

    func testProgressionScenarios() {
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 60, increment: 2.5, completedFiveSeries: []), 60)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 60, increment: 2.5, completedFiveSeries: [true, true, true]), 67.5)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 60, increment: 2.5, completedFiveSeries: [true, false, true, false, true]), 67.5)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 80, increment: 5, completedFiveSeries: [false, false, false]), 80)
    }

    func testGeneratedWorkoutExactWeights() {
        let exercises = [
            Exercise(name: "Bench Press", type: .weighted, initial10RM: 60, weightIncrement: 2.5, unit: .kg, sortOrder: 0),
            Exercise(name: "Deadlift", type: .weighted, initial10RM: 80, weightIncrement: 5, unit: .kg, sortOrder: 1),
        ]

        let heavy = DeLormeEngine.generateSeries(exercises: exercises, dayType: .heavy, week: 1)
        XCTAssertEqual(heavy.count, 2)
        XCTAssertEqual(heavy[0].name, "Bench Press")
        XCTAssertEqual(heavy[0].sets.map(\.weight), [30, 45, 60])
        XCTAssertEqual(heavy[0].sets.map(\.reps), [5, 5, 5])
        XCTAssertEqual(heavy[1].name, "Deadlift")
        XCTAssertEqual(heavy[1].sets.map(\.weight), [40, 60, 80])

        let light = DeLormeEngine.generateSeries(exercises: exercises, dayType: .light, week: 1)
        XCTAssertEqual(light[0].sets.map(\.weight), [30])
        XCTAssertEqual(light[1].sets.map(\.weight), [40])

        let medium = DeLormeEngine.generateSeries(exercises: exercises, dayType: .medium, week: 1)
        XCTAssertEqual(medium[0].sets.map(\.weight), [30, 45])
        XCTAssertEqual(medium[1].sets.map(\.weight), [40, 60])

        let introHeavy = DeLormeEngine.generateSeries(exercises: exercises, dayType: .heavy, week: -1)
        XCTAssertEqual(introHeavy[0].sets.map(\.weight), [30, 45])
        XCTAssertEqual(introHeavy[0].sets.map(\.intensity), [0.5, 0.75])
    }

    func testWeek7OnlyHeavy() {
        let exercises = Exercise.defaultExercises()
        let heavy = DeLormeEngine.generateSeries(exercises: exercises, dayType: .heavy, week: 7)
        XCTAssertEqual(heavy[0].sets.count, 3)
    }
}
