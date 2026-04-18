import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var type: ExerciseType
    var initial10RM: Double
    var final10RM: Double
    var weightIncrement: Double
    var unit: WeightUnit
    var sortOrder: Int
    var program: Program?

    init(
        name: String,
        type: ExerciseType,
        initial10RM: Double,
        weightIncrement: Double,
        unit: WeightUnit = .kg,
        sortOrder: Int
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.initial10RM = initial10RM
        self.final10RM = initial10RM
        self.weightIncrement = weightIncrement
        self.unit = unit
        self.sortOrder = sortOrder
    }

    static func defaultExercises(unit: WeightUnit = .kg) -> [Exercise] {
        let benchIncrement: Double = unit == .kg ? 2.5 : 5
        let deadliftIncrement: Double = unit == .kg ? 5 : 10
        return [
            Exercise(
                name: "Bench Press",
                type: .weighted,
                initial10RM: unit == .kg ? 60 : 135,
                weightIncrement: benchIncrement,
                unit: unit,
                sortOrder: 0
            ),
            Exercise(
                name: "Deadlift",
                type: .weighted,
                initial10RM: unit == .kg ? 80 : 175,
                weightIncrement: deadliftIncrement,
                unit: unit,
                sortOrder: 1
            )
        ]
    }
}
