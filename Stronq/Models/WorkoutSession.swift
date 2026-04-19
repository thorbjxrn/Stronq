import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var weekNumber: Int
    var dayType: DayType
    var duration: TimeInterval
    var isCompleted: Bool
    var program: Program?

    @Relationship(deleteRule: .cascade, inverse: \CompletedSet.session)
    var completedSets: [CompletedSet]

    init(
        date: Date = .now,
        weekNumber: Int,
        dayType: DayType
    ) {
        self.id = UUID()
        self.date = date
        self.weekNumber = weekNumber
        self.dayType = dayType
        self.duration = 0
        self.isCompleted = false
        self.completedSets = []
    }

    var totalVolume: Double {
        completedSets
            .filter { $0.isCompleted }
            .reduce(0) { $0 + $1.actualWeight * Double($1.actualReps) }
    }

    var completedSetCount: Int {
        completedSets.filter(\.isCompleted).count
    }

    var totalSetCount: Int {
        completedSets.count
    }

    func setsForExercise(_ exerciseName: String) -> [CompletedSet] {
        completedSets
            .filter { $0.exerciseName == exerciseName }
            .sorted { ($0.seriesNumber, $0.setNumber) < ($1.seriesNumber, $1.setNumber) }
    }

    func maxSeriesCompleted(for exerciseName: String) -> Int {
        let exerciseSets = setsForExercise(exerciseName)
        let completedBySeriesAndIntensity = exerciseSets
            .filter { $0.isCompleted && $0.actualReps >= $0.targetReps }
        let fullSeries = Set(completedBySeriesAndIntensity.map(\.seriesNumber))
        return fullSeries.count
    }
}
