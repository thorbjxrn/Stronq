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
        [
            Exercise(
                name: "Push-up",
                type: .bodyweight,
                initial10RM: 0,
                weightIncrement: 0,
                unit: unit,
                sortOrder: 0
            ),
            Exercise(
                name: "1-Arm Pulldown",
                type: .weighted,
                initial10RM: 25,
                weightIncrement: 2.5,
                unit: unit,
                sortOrder: 1
            ),
            Exercise(
                name: "Zercher Squat",
                type: .weighted,
                initial10RM: 45,
                weightIncrement: 5,
                unit: unit,
                sortOrder: 2
            )
        ]
    }
}
