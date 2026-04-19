import SwiftUI
import SwiftData

struct ProgramOverviewView: View {
    @Environment(ThemeManager.self) private var theme
    @Query private var programs: [Program]
    @Query private var allSessions: [WorkoutSession]
    @State private var selectedWeek: Int?

    private var program: Program? { programs.first }

    func findSession(week: Int, dayType: DayType) -> WorkoutSession? {
        allSessions.first { $0.weekNumber == week && $0.dayType == dayType && $0.isCompleted }
    }

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
                                    allSessions: allSessions,
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

                        NavigationLink {
                            HowItWorksView()
                        } label: {
                            Text("How it works →")
                                .font(.subheadline)
                                .foregroundStyle(theme.accentColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
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
    let allSessions: [WorkoutSession]
    let isCurrentWeek: Bool
    let isExpanded: Bool
    let theme: ThemeManager

    func findSession(_ dayType: DayType) -> WorkoutSession? {
        allSessions.first { $0.weekNumber == week && $0.dayType == dayType }
    }

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
                let session = findSession(dayType)
                let done = session?.isCompleted == true
                let exerciseNames = Set((session?.completedSets ?? []).map(\.exerciseName))
                let allHitFive = done && !exerciseNames.isEmpty && exerciseNames.allSatisfy { name in
                    let max = (session?.completedSets ?? [])
                        .filter { $0.exerciseName == name && $0.isCompleted }
                        .map(\.seriesNumber).max() ?? 0
                    return max >= 5
                }

                VStack(spacing: 3) {
                    Circle()
                        .fill(allHitFive ? theme.completedColor :
                              done ? theme.accentColor :
                              Color.white.opacity(0.1))
                        .frame(width: 20, height: 20)
                        .overlay {
                            if allHitFive {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.black)
                            } else if done {
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
        let mondayPerExercise = mondaySeriesPerExercise
        let mode = DeLormeEngine.seriesCount(
            week: week,
            dayType: dayType,
            mondaySeriesCount: mondaySeriesForWeek
        )
        let perExerciseModes: [(name: String, count: Int)] = program.exercises
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { ex in
                let mc = mondayPerExercise[ex.name]
                let m = DeLormeEngine.seriesCount(week: week, dayType: dayType, mondaySeriesCount: mc)
                switch m {
                case .fixed(let n): return (name: ex.name, count: n)
                case .max: return (name: ex.name, count: 0)
                }
            }
        let hasVariableSeries = Set(perExerciseModes.map(\.count)).count > 1
        let planned = DeLormeEngine.generateSeries(
            exercises: program.exercises,
            dayType: dayType,
            week: week
        )
        let session = findSession(dayType)
        let isDone = session?.isCompleted == true
        let exerciseSeries: [(name: String, count: Int)] = isDone ? program.exercises.sorted(by: { $0.sortOrder < $1.sortOrder }).map { ex in
            let count = (session?.completedSets ?? [])
                .filter { $0.exerciseName == ex.name && $0.isCompleted }
                .map(\.seriesNumber).max() ?? 0
            return (name: ex.name, count: count)
        } : []
        let allHitFive = isDone && !exerciseSeries.isEmpty && exerciseSeries.allSatisfy { $0.count >= 5 }

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dayType.rawValue)
                    .font(.subheadline.bold())
                    .foregroundStyle(allHitFive ? theme.completedColor :
                                     isDone ? theme.accentColor : theme.accentColor)

                if allHitFive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(theme.completedColor)
                }

                Spacer()

                if isDone {
                    HStack(spacing: 8) {
                        ForEach(exerciseSeries, id: \.name) { es in
                            Text("\(es.count)")
                                .font(.caption2.bold())
                                .foregroundStyle(es.count >= 5 ? theme.completedColor : theme.accentColor)
                        }
                    }
                } else if hasVariableSeries {
                    HStack(spacing: 6) {
                        ForEach(perExerciseModes, id: \.name) { em in
                            Text("\(em.count)")
                                .font(.caption2.bold())
                                .foregroundStyle(theme.textSecondary)
                        }
                        Text("series")
                            .font(.caption2)
                            .foregroundStyle(theme.textSecondary)
                    }
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
                        Text(set.shortDisplayWeight)
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

    private var mondaySeriesPerExercise: [String: Int] {
        let session = allSessions.first {
            $0.weekNumber == week && $0.dayType == .heavy && $0.isCompleted
        }
        guard let session else { return [:] }
        var result: [String: Int] = [:]
        for exercise in program.exercises {
            let allSets = session.completedSets.filter { $0.exerciseName == exercise.name }
            let seriesNumbers = Set(allSets.map(\.seriesNumber))
            result[exercise.name] = seriesNumbers.filter { series in
                let setsInSeries = allSets.filter { $0.seriesNumber == series }
                return !setsInSeries.isEmpty && setsInSeries.allSatisfy(\.isCompleted)
            }.count
        }
        return result
    }

    private var mondaySeriesForWeek: Int? {
        let session = allSessions.first {
            $0.weekNumber == week && $0.dayType == .heavy && $0.isCompleted
        }
        guard let session else { return nil }
        let allSets = session.completedSets
        let seriesNumbers = Set(allSets.map(\.seriesNumber))
        let completedCount = seriesNumbers.filter { series in
            let setsInSeries = allSets.filter { $0.seriesNumber == series }
            return !setsInSeries.isEmpty && setsInSeries.allSatisfy(\.isCompleted)
        }.count
        return completedCount
    }
}
