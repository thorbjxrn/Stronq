import XCTest
@testable import BearTraining

final class DeLormeEngineTests: XCTestCase {

    // MARK: - 10RM Progression

    func testPulldown10RMProgression() {
        // Initial 10RM = 25, increment = 2.5
        // All series completed (5 each week)
        let history = [5, 5, 5, 5, 5, 5]

        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 25, increment: 2.5, weeklySeriesHistory: history, currentWeek: -1), 25)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 25, increment: 2.5, weeklySeriesHistory: history, currentWeek: 0), 25)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 25, increment: 2.5, weeklySeriesHistory: history, currentWeek: 1), 25)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 25, increment: 2.5, weeklySeriesHistory: history, currentWeek: 2), 27.5)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 25, increment: 2.5, weeklySeriesHistory: history, currentWeek: 3), 30)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 25, increment: 2.5, weeklySeriesHistory: history, currentWeek: 4), 32.5)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 25, increment: 2.5, weeklySeriesHistory: history, currentWeek: 5), 35)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 25, increment: 2.5, weeklySeriesHistory: history, currentWeek: 6), 37.5)
    }

    func testZercher10RMProgression() {
        // Initial 10RM = 45, increment = 5
        let history = [5, 5, 5, 5, 5, 5]

        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 45, increment: 5, weeklySeriesHistory: history, currentWeek: 1), 45)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 45, increment: 5, weeklySeriesHistory: history, currentWeek: 2), 50)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 45, increment: 5, weeklySeriesHistory: history, currentWeek: 3), 55)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 45, increment: 5, weeklySeriesHistory: history, currentWeek: 4), 60)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 45, increment: 5, weeklySeriesHistory: history, currentWeek: 5), 65)
        XCTAssertEqual(DeLormeEngine.calculate10RM(initial10RM: 45, increment: 5, weeklySeriesHistory: history, currentWeek: 6), 70)
    }

    func testConditionalProgressionStallsOnIncompleteSeries() {
        // Week 3 push-ups had 3.2 series (< 5), but pulldown had 5
        // For an exercise where series < 5, weight should NOT increase
        let history = [5, 5, 3, 5, 5]

        // Week 4: prev series (week 3) = 3 < 5, so no increment
        let week4 = DeLormeEngine.calculate10RM(initial10RM: 25, increment: 2.5, weeklySeriesHistory: history, currentWeek: 4)
        XCTAssertEqual(week4, 30) // 25 + 2.5 + 2.5 + 0 (stall at week 3)

        // Week 5: prev series (week 4) = 5, so increment resumes
        let week5 = DeLormeEngine.calculate10RM(initial10RM: 25, increment: 2.5, weeklySeriesHistory: history, currentWeek: 5)
        XCTAssertEqual(week5, 32.5) // 30 + 2.5
    }

    // MARK: - Heavy Day Weights (Zercher matches spreadsheet exactly)

    func testZercherHeavyDayWeights() {
        let history = [5, 5, 5, 5, 5, 5]

        // Week 1: 50%=22.5, 75%=33.75, 100%=45
        let w1_50 = DeLormeEngine.calculateSetWeight(tenRM: 45, nextWeekTenRM: 50, dayType: .heavy, intensity: 0.5, week: 1)
        let w1_75 = DeLormeEngine.calculateSetWeight(tenRM: 45, nextWeekTenRM: 50, dayType: .heavy, intensity: 0.75, week: 1)
        let w1_100 = DeLormeEngine.calculateSetWeight(tenRM: 45, nextWeekTenRM: 50, dayType: .heavy, intensity: 1.0, week: 1)
        XCTAssertEqual(w1_50, 22.5)
        XCTAssertEqual(w1_75, 33.75)
        XCTAssertEqual(w1_100, 45)

        // Week 4: 50%=30, 75%=45, 100%=60
        let rm4 = DeLormeEngine.calculate10RM(initial10RM: 45, increment: 5, weeklySeriesHistory: history, currentWeek: 4)
        XCTAssertEqual(rm4, 60)
        XCTAssertEqual(rm4 * 0.5, 30)
        XCTAssertEqual(rm4 * 0.75, 45)

        // Week 6: 50%=35, 75%=52.5, 100%=70
        let rm6 = DeLormeEngine.calculate10RM(initial10RM: 45, increment: 5, weeklySeriesHistory: history, currentWeek: 6)
        XCTAssertEqual(rm6, 70)
        XCTAssertEqual(rm6 * 0.5, 35)
        XCTAssertEqual(rm6 * 0.75, 52.5)
    }

    // MARK: - Light/Medium Day Weights (use next week's 10RM)

    func testLightDayUsesNextWeekWeights() {
        // Week 1 Light Zercher: 50% = next_week_10RM * 0.5 = 50 * 0.5 = 25
        let w = DeLormeEngine.calculateSetWeight(tenRM: 45, nextWeekTenRM: 50, dayType: .light, intensity: 0.5, week: 1)
        XCTAssertEqual(w, 25)
    }

    func testMediumDayUsesNextWeekWeights() {
        // Week 1 Medium Zercher: 50% = 25, 75% = 37.5
        let w50 = DeLormeEngine.calculateSetWeight(tenRM: 45, nextWeekTenRM: 50, dayType: .medium, intensity: 0.5, week: 1)
        let w75 = DeLormeEngine.calculateSetWeight(tenRM: 45, nextWeekTenRM: 50, dayType: .medium, intensity: 0.75, week: 1)
        XCTAssertEqual(w50, 25)
        XCTAssertEqual(w75, 37.5)
    }

    // MARK: - Intensity Levels Per Day Type

    func testHeavyDayHasThreeIntensityLevels() {
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .heavy, week: 1), [0.5, 0.75, 1.0])
    }

    func testMediumDayHasTwoIntensityLevels() {
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .medium, week: 1), [0.5, 0.75])
    }

    func testLightDayHasOneIntensityLevel() {
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .light, week: 1), [0.5])
    }

    // MARK: - Intro Cycle

    func testIntroWeekMinus1OnlyTwoLevels() {
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .heavy, week: -1), [0.5, 0.75])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .light, week: -1), [0.5, 0.75])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .medium, week: -1), [0.5, 0.75])
    }

    func testIntroWeek0HeavyHasThreeLevels() {
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .heavy, week: 0), [0.5, 0.75, 1.0])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .light, week: 0), [0.5, 0.75])
        XCTAssertEqual(DeLormeEngine.intensityLevels(for: .medium, week: 0), [0.5, 0.75])
    }

    func testIntroUsesInitialWeights() {
        let w = DeLormeEngine.calculateSetWeight(tenRM: 25, nextWeekTenRM: 25, dayType: .heavy, intensity: 0.5, week: -1)
        XCTAssertEqual(w, 12.5)
    }

    // MARK: - Series Count

    func testSeriesCountIntroCycle() {
        // Week -1: H=3, L=4, M=5
        XCTAssertEqual(DeLormeEngine.seriesCount(week: -1, dayType: .heavy, exerciseType: .weighted), 3)
        XCTAssertEqual(DeLormeEngine.seriesCount(week: -1, dayType: .light, exerciseType: .weighted), 4)
        XCTAssertEqual(DeLormeEngine.seriesCount(week: -1, dayType: .medium, exerciseType: .weighted), 5)

        // Week 0: H=2, L=7, M=5
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 0, dayType: .heavy, exerciseType: .weighted), 2)
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 0, dayType: .light, exerciseType: .weighted), 7)
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 0, dayType: .medium, exerciseType: .weighted), 5)
    }

    func testSeriesCountMainCycle() {
        // Weeks 1-2: all 5
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 1, dayType: .heavy, exerciseType: .bodyweight), 5)
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 1, dayType: .heavy, exerciseType: .weighted), 5)

        // Week 3: push-ups 3.2, weighted 5
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 3, dayType: .heavy, exerciseType: .bodyweight), 3.2)
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 3, dayType: .heavy, exerciseType: .weighted), 5)

        // Week 4: push-ups 4, weighted 5
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 4, dayType: .heavy, exerciseType: .bodyweight), 4)
        XCTAssertEqual(DeLormeEngine.seriesCount(week: 4, dayType: .heavy, exerciseType: .weighted), 5)
    }

    // MARK: - Push-up Variants

    func testPushUpVariants() {
        XCTAssertEqual(PushUpVariant.from(intensity: 0.5), .regular)
        XCTAssertEqual(PushUpVariant.from(intensity: 0.75), .archer)
        XCTAssertEqual(PushUpVariant.from(intensity: 1.0), .oneArm)
    }

    // MARK: - Full Workout Generation

    func testGenerateWeek1HeavyWorkout() {
        let exercises = Exercise.defaultExercises()
        let history: [String: [Int]] = [:]

        let workout = DeLormeEngine.generateWorkout(
            exercises: exercises,
            week: 1,
            dayType: .heavy,
            seriesHistory: history
        )

        XCTAssertEqual(workout.exercises.count, 3)

        // Push-up: 3 sets, 5 series
        let pushUp = workout.exercises[0]
        XCTAssertEqual(pushUp.sets.count, 3)
        XCTAssertEqual(pushUp.seriesCount, 5)
        XCTAssertEqual(pushUp.sets[0].pushUpVariant, .regular)
        XCTAssertEqual(pushUp.sets[1].pushUpVariant, .archer)
        XCTAssertEqual(pushUp.sets[2].pushUpVariant, .oneArm)

        // Pulldown: 3 sets (50/75/100% of 25), 5 series
        let pulldown = workout.exercises[1]
        XCTAssertEqual(pulldown.sets.count, 3)
        XCTAssertEqual(pulldown.seriesCount, 5)
        XCTAssertEqual(pulldown.sets[0].weight, 12.5)
        XCTAssertEqual(pulldown.sets[1].weight, 18.75)
        XCTAssertEqual(pulldown.sets[2].weight, 25)

        // Zercher: 3 sets (50/75/100% of 45), 5 series
        let zercher = workout.exercises[2]
        XCTAssertEqual(zercher.sets.count, 3)
        XCTAssertEqual(zercher.seriesCount, 5)
        XCTAssertEqual(zercher.sets[0].weight, 22.5)
        XCTAssertEqual(zercher.sets[1].weight, 33.75)
        XCTAssertEqual(zercher.sets[2].weight, 45)
    }

    func testGenerateWeek1LightWorkout() {
        let exercises = Exercise.defaultExercises()
        let history: [String: [Int]] = [:]

        let workout = DeLormeEngine.generateWorkout(
            exercises: exercises,
            week: 1,
            dayType: .light,
            seriesHistory: history
        )

        // Light day: only 1 intensity level (50%)
        let pulldown = workout.exercises[1]
        XCTAssertEqual(pulldown.sets.count, 1)

        // Zercher Light uses next week's 10RM (50): 50% = 25
        let zercher = workout.exercises[2]
        XCTAssertEqual(zercher.sets.count, 1)
        XCTAssertEqual(zercher.sets[0].weight, 25)
    }

    func testGenerateWeek1MediumWorkout() {
        let exercises = Exercise.defaultExercises()
        let history: [String: [Int]] = [:]

        let workout = DeLormeEngine.generateWorkout(
            exercises: exercises,
            week: 1,
            dayType: .medium,
            seriesHistory: history
        )

        // Medium day: 2 intensity levels (50%, 75%)
        // Zercher Medium uses next week's 10RM (50): 50%=25, 75%=37.5
        let zercher = workout.exercises[2]
        XCTAssertEqual(zercher.sets.count, 2)
        XCTAssertEqual(zercher.sets[0].weight, 25)
        XCTAssertEqual(zercher.sets[1].weight, 37.5)
    }
}
