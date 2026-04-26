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
    var programType: String

    @Relationship(deleteRule: .cascade, inverse: \Exercise.program)
    var exercises: [Exercise]

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSession.program)
    var sessions: [WorkoutSession]

    init(
        programType: String = "delorme-classic",
        startDate: Date = .now,
        currentWeek: Int = 1,
        introCycleEnabled: Bool = false
    ) {
        self.id = UUID()
        self.programType = programType
        self.startDate = startDate
        self.currentWeek = introCycleEnabled ? -1 : 1
        self.introCycleEnabled = introCycleEnabled
        self.setRestDuration = 60
        self.seriesRestDuration = 180
        self.exercises = []
        self.sessions = []
    }

    var definition: ProgramDefinition? {
        ProgramRegistry.definition(for: programType)
    }

    @Transient var restBetweenSets: Int {
        get { setRestDuration ?? 60 }
        set { setRestDuration = newValue }
    }

    @Transient var restBetweenSeries: Int {
        get { seriesRestDuration ?? 180 }
        set { seriesRestDuration = newValue }
    }

    var firstWeek: Int { introCycleEnabled ? -1 : 1 }

    var lastWeek: Int {
        definition?.cycleLength ?? 7
    }

    var weekRange: ClosedRange<Int> {
        firstWeek...lastWeek
    }

    func sessionsForWeek(_ week: Int) -> [WorkoutSession] {
        sessions.filter { $0.weekNumber == week }
    }

    func session(week: Int, dayName: String) -> WorkoutSession? {
        sessions.first { $0.weekNumber == week && $0.dayName == dayName }
    }

    func isWeekComplete(_ week: Int) -> Bool {
        guard let def = definition else { return false }
        let dayNames: [String]
        if def.cycleLength == 7 && week == 7 {
            dayNames = [def.days[0].name]
        } else {
            dayNames = def.days.map(\.name)
        }
        return dayNames.allSatisfy { dayName in
            session(week: week, dayName: dayName)?.isCompleted == true
        }
    }
}
