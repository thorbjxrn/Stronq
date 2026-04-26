import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var weekNumber: Int
    @Attribute(originalName: "dayType") var dayName: String
    var duration: TimeInterval
    var isCompleted: Bool
    var program: Program?

    @Relationship(deleteRule: .cascade, inverse: \CompletedSet.session)
    var completedSets: [CompletedSet]

    init(
        date: Date = .now,
        weekNumber: Int,
        dayName: String
    ) {
        self.id = UUID()
        self.date = date
        self.weekNumber = weekNumber
        self.dayName = dayName
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
            .sorted { ($0.groupNumber, $0.setNumber) < ($1.groupNumber, $1.setNumber) }
    }

    func fullyCompletedGroupCount(for exerciseName: String) -> Int {
        let sets = completedSets.filter { $0.exerciseName == exerciseName }
        let groupNumbers = Set(sets.map(\.groupNumber))
        return groupNumbers.filter { group in
            let setsInGroup = sets.filter { $0.groupNumber == group }
            return !setsInGroup.isEmpty && setsInGroup.allSatisfy(\.isCompleted)
        }.count
    }
}
