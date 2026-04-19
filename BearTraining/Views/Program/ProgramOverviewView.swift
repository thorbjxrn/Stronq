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
                        VStack(spacing: 10) {
                            ForEach(weeksToShow(program), id: \.self) { week in
                                WeekCard(
                                    week: week,
                                    program: program,
                                    isCurrentWeek: week == program.currentWeek,
                                    isExpanded: selectedWeek == week,
                                    theme: theme
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        selectedWeek = selectedWeek == week ? nil : week
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
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

// MARK: - Week Card

struct WeekCard: View {
    let week: Int
    let program: Program
    let isCurrentWeek: Bool
    let isExpanded: Bool
    let theme: ThemeManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(weekLabel)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                        if isCurrentWeek {
                            Text("NOW")
                                .font(.system(size: 10, weight: .heavy))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(theme.accentColor, in: Capsule())
                                .foregroundStyle(.black)
                        }
                    }
                    if week == 7 {
                        Text("Final Test")
                            .font(.caption2)
                            .foregroundStyle(theme.textSecondary)
                    }
                }

                Spacer()

                dayDots
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if isExpanded {
                Divider()
                    .overlay(theme.backgroundColor)
                expandedContent
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(theme.cardColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            isCurrentWeek ? theme.accentColor.opacity(0.5) : .clear,
                            lineWidth: 1.5
                        )
                )
        )
    }

    // MARK: - Week Label

    private var weekLabel: String {
        switch week {
        case -1: "Intro 1"
        case 0: "Intro 2"
        case 7: "Week 7"
        default: "Week \(week)"
        }
    }

    // MARK: - Day Dots

    private var dayDots: some View {
        let days: [DayType] = week == 7 ? [.heavy] : DayType.allCases
        return HStack(spacing: 8) {
            ForEach(days, id: \.self) { dayType in
                let done = program.session(week: week, dayType: dayType)?.isCompleted == true
                VStack(spacing: 3) {
                    Circle()
                        .fill(done ? theme.completedColor : Color.white.opacity(0.1))
                        .frame(width: 20, height: 20)
                        .overlay {
                            if done {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.black)
                            }
                        }
                    Text(dayType.shortLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                }
            }
        }
    }

    // MARK: - Expanded Content

    @ViewBuilder
    private var expandedContent: some View {
        let days: [DayType] = week == 7 ? [.heavy] : DayType.allCases

        VStack(spacing: 12) {
            ForEach(days, id: \.self) { dayType in
                dayRow(dayType)
            }
        }
    }

    private func dayRow(_ dayType: DayType) -> some View {
        let mode = DeLormeEngine.seriesCount(
            week: week,
            dayType: dayType,
            mondaySeriesCount: mondaySeriesForWeek
        )
        let planned = DeLormeEngine.generateSeries(
            exercises: program.exercises,
            dayType: dayType,
            week: week
        )
        let session = program.session(week: week, dayType: dayType)
        let isDone = session?.isCompleted == true
        let completedSeries = session?.completedSets.map(\.seriesNumber).max() ?? 0

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dayType.rawValue)
                    .font(.subheadline.bold())
                    .foregroundStyle(isDone ? theme.completedColor : theme.accentColor)

                if isDone {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(theme.completedColor)
                }

                Spacer()

                if isDone {
                    Text("\(completedSeries) series done")
                        .font(.caption2)
                        .foregroundStyle(theme.completedColor)
                } else {
                    switch mode {
                    case .max:
                        Label("max series", systemImage: "flame")
                            .font(.caption2)
                            .foregroundStyle(theme.accentColor.opacity(0.8))
                    case .fixed(let n):
                        Text("\(n) series")
                            .font(.caption2)
                            .foregroundStyle(theme.textSecondary)
                    }
                }
            }

            // Exercises
            ForEach(planned, id: \.name) { exercise in
                HStack(spacing: 0) {
                    Text(exercise.name)
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(exercise.sets, id: \.intensity) { set in
                        Text(set.displayWeight)
                            .font(.system(.caption, design: .monospaced, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .frame(width: 44, alignment: .trailing)
                    }
                }
            }
        }
        .padding(12)
        .background(theme.backgroundColor.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
    }

    private var mondaySeriesForWeek: Int? {
        let session = program.sessions.first {
            $0.weekNumber == week && $0.dayType == .heavy && $0.isCompleted
        }
        guard let session else { return nil }
        return session.completedSets.map(\.seriesNumber).max()
    }
}
