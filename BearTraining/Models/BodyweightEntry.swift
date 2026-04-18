import Foundation
import SwiftData

@Model
final class BodyweightEntry {
    var id: UUID
    var date: Date
    var weight: Double
    var unit: WeightUnit

    init(date: Date = .now, weight: Double, unit: WeightUnit = .kg) {
        self.id = UUID()
        self.date = date
        self.weight = weight
        self.unit = unit
    }
}
