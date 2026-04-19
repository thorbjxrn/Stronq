import Foundation
import SwiftData

@Model
final class CompletedSet {
    var id: UUID
    var exerciseName: String
    var seriesNumber: Int
    var setNumber: Int
    var targetWeight: Double
    var actualWeight: Double
    var targetReps: Int
    var actualReps: Int
    var intensity: Double
    var isCompleted: Bool
    var completedAt: Date?
    var pushUpVariant: PushUpVariant?
    var session: WorkoutSession?

    init(
        exerciseName: String,
        seriesNumber: Int,
        setNumber: Int,
        targetWeight: Double,
        targetReps: Int = 5,
        intensity: Double,
        pushUpVariant: PushUpVariant? = nil
    ) {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.seriesNumber = seriesNumber
        self.setNumber = setNumber
        self.targetWeight = targetWeight
        self.actualWeight = targetWeight
        self.targetReps = targetReps
        self.actualReps = targetReps
        self.intensity = intensity
        self.isCompleted = false
        self.pushUpVariant = pushUpVariant
    }

    var displayWeight: String {
        if pushUpVariant != nil {
            return pushUpVariant?.rawValue ?? "Regular"
        }
        return String(format: "%.2f", targetWeight)
    }
}
