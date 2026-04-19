import HealthKit
import SwiftUI

@Observable
@MainActor
final class HealthKitManager {
    private let healthStore = HKHealthStore()
    private(set) var isAuthorized = false

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }

        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .bodyMass)!
        ]

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!
        ]

        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            isAuthorized = true
            return true
        } catch {
            isAuthorized = false
            return false
        }
    }

    func saveWorkout(
        duration: TimeInterval,
        date: Date,
        totalVolume: Double
    ) async {
        guard isAuthorized else { return }

        let config = HKWorkoutConfiguration()
        config.activityType = .traditionalStrengthTraining

        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: config, device: .local())
        do {
            let start = date.addingTimeInterval(-duration)
            try await builder.beginCollection(at: start)
            try await builder.endCollection(at: date)
            try await builder.finishWorkout()
        } catch {
            // Silently fail — HealthKit write errors shouldn't block the app
        }
    }

    func readBodyweightHistory(limit: Int = 100) async -> [(date: Date, weight: Double)] {
        guard isAuthorized else { return [] }

        let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: bodyMassType,
                predicate: nil,
                limit: limit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                let results = (samples as? [HKQuantitySample])?.map { sample in
                    (date: sample.startDate,
                     weight: sample.quantity.doubleValue(for: .gramUnit(with: .kilo)))
                } ?? []
                continuation.resume(returning: results)
            }
            healthStore.execute(query)
        }
    }

    func saveBodyweight(_ weight: Double, unit: WeightUnit = .kg, date: Date = .now) async {
        guard isAuthorized else { return }

        let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let hkUnit: HKUnit = unit == .kg ? .gramUnit(with: .kilo) : .pound()
        let quantity = HKQuantity(unit: hkUnit, doubleValue: weight)
        let sample = HKQuantitySample(type: bodyMassType, quantity: quantity, start: date, end: date)

        do {
            try await healthStore.save(sample)
        } catch {
            // Silently fail
        }
    }
}
