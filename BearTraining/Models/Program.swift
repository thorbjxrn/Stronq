import Foundation
import SwiftData

@Model
final class Program {
    var id: UUID
    var startDate: Date
    var currentWeek: Int
    var introCycleEnabled: Bool
    var setRestDuration: Int?
    var seriesRestDuration: Int?
    var exerciseOrderRaw: String?

    @Relationship(deleteRule: .cascade, inverse: \Exercise.program)
    var exercises: [Exercise]

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSession.program)
    var sessions: [WorkoutSession]

    init(
        startDate: Date = .now,
        currentWeek: Int = 1,
        introCycleEnabled: Bool = false
    ) {
        self.id = UUID()
        self.startDate = startDate
        self.currentWeek = introCycleEnabled ? -1 : 1
        self.introCycleEnabled = introCycleEnabled
        self.setRestDuration = 60
        self.seriesRestDuration = 180
        self.exerciseOrderRaw = ExerciseOrder.sequential.rawValue
        self.exercises = []
        self.sessions = []
    }

    @Transient var restBetweenSets: Int {
        get { setRestDuration ?? 60 }
        set { setRestDuration = newValue }
    }

    @Transient var restBetweenSeries: Int {
        get { seriesRestDuration ?? 180 }
        set { seriesRestDuration = newValue }
    }

    @Transient var exerciseOrder: ExerciseOrder {
        get { ExerciseOrder(rawValue: exerciseOrderRaw ?? "") ?? .sequential }
        set { exerciseOrderRaw = newValue.rawValue }
    }

    var firstWeek: Int { introCycleEnabled ? -1 : 1 }
    var lastWeek: Int { 7 }

    var weekRange: ClosedRange<Int> {
        firstWeek...lastWeek
    }

    func sessionsForWeek(_ week: Int) -> [WorkoutSession] {
        sessions.filter { $0.weekNumber == week }
    }

    func session(week: Int, dayType: DayType) -> WorkoutSession? {
        sessions.first { $0.weekNumber == week && $0.dayType == dayType }
    }

    func isWeekComplete(_ week: Int) -> Bool {
        if week == 7 {
            return session(week: 7, dayType: .heavy)?.isCompleted == true
        }
        return DayType.allCases.allSatisfy { dayType in
            session(week: week, dayType: dayType)?.isCompleted == true
        }
    }
}
