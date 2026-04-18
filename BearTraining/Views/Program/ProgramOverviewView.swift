import SwiftUI
import SwiftData

struct ProgramOverviewView: View {
    @Environment(ThemeManager.self) private var theme
    @Query private var programs: [Program]
    @State private var selectedWeek: Int?

    private var program: Program? { programs.first }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                if let program {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(weeksToShow(program), id: \.self) { week in
                                WeekRowView(
                                    week: week,
                                    program: program,
                                    isCurrentWeek: week == program.currentWeek,
                                    isExpanded: selectedWeek == week,
                                    theme: theme
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedWeek = selectedWeek == week ? nil : week
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("No program configured.")
                        .foregroundStyle(theme.textSecondary)
                }
            }
            .navigationTitle("Program")
        }
    }

    private func weeksToShow(_ program: Program) -> [Int] {
        Array(program.weekRange)
    }
}

struct WeekRowView: View {
    let week: Int
    let program: Program
    let isCurrentWeek: Bool
    let isExpanded: Bool
    let theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(weekLabel)
                        .font(.headline)
                    if week == 7 {
                        Text("Final Test (Optional)")
                            .font(.caption)
                            .foregroundStyle(theme.textSecondary)
                    } else if week < 1 {
                        Text("Intro Cycle")
                            .font(.caption)
                            .foregroundStyle(theme.textSecondary)
                    }
                }

                Spacer()

                if isCurrentWeek {
                    Text("CURRENT")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(theme.accentColor)
                        .foregroundStyle(.black)
                        .clipShape(Capsule())
                }

                dayIndicators
            }

            if isExpanded {
                expandedContent
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isCurrentWeek ? theme.accentColor : .clear, lineWidth: 2)
                )
        )
    }

    private var weekLabel: String {
        switch week {
        case -1: "Week -1"
        case 0: "Week 0"
        case 7: "Week 7"
        default: "Week \(week)"
        }
    }

    private var dayIndicators: some View {
        HStack(spacing: 6) {
            let days: [DayType] = week == 7 ? [.heavy] : DayType.allCases
            ForEach(days, id: \.self) { dayType in
                let completed = program.session(week: week, dayType: dayType)?.isCompleted == true
                VStack(spacing: 2) {
                    Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                        .font(.caption)
                        .foregroundStyle(completed ? theme.completedColor : theme.textSecondary)
                    Text(dayType.shortLabel)
                        .font(.system(size: 9))
                        .foregroundStyle(theme.textSecondary)
                }
            }
        }
    }

    @ViewBuilder
    private var expandedContent: some View {
        let seriesHistory = buildSeriesHistoryForDisplay(program: program)
        let days: [DayType] = week == 7 ? [.heavy] : DayType.allCases

        ForEach(days, id: \.self) { dayType in
            VStack(alignment: .leading, spacing: 4) {
                Text(dayType.rawValue)
                    .font(.subheadline.bold())
                    .foregroundStyle(theme.accentColor)

                let workout = DeLormeEngine.generateWorkout(
                    exercises: program.exercises,
                    week: week,
                    dayType: dayType,
                    seriesHistory: seriesHistory
                )

                ForEach(workout.exercises, id: \.name) { exercise in
                    HStack {
                        Text(exercise.name)
                            .font(.caption)
                        Spacer()
                        Text(exercise.sets.map(\.displayWeight).joined(separator: " / "))
                            .font(.caption.monospaced())
                        if exercise.type == .weighted {
                            Text(exercise.unit.symbol)
                                .font(.system(size: 10))
                                .foregroundStyle(theme.textSecondary)
                        }
                    }
                    .foregroundStyle(theme.textSecondary)
                }
            }
            .padding(.top, 4)
        }
    }

    private func buildSeriesHistoryForDisplay(program: Program) -> [String: [Int]] {
        var history: [String: [Int]] = [:]
        for exercise in program.exercises {
            var weeklyHistory: [Int] = []
            for w in 1...6 {
                let session = program.sessions.first {
                    $0.weekNumber == w && $0.dayType == .heavy && $0.isCompleted
                }
                let completed = session?.maxSeriesCompleted(for: exercise.name) ?? 5
                weeklyHistory.append(completed)
            }
            history[exercise.name] = weeklyHistory
        }
        return history
    }
}
