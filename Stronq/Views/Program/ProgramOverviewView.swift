import SwiftUI
import SwiftData

struct ProgramOverviewView: View {
    @Environment(ThemeManager.self) private var theme
    @Query private var programs: [Program]
    @Query private var allSessions: [WorkoutSession]
    @State private var selectedWeek: Int?

    private var program: Program? { programs.first }

    func findSession(week: Int, dayName: String) -> WorkoutSession? {
        allSessions.first { $0.weekNumber == week && $0.dayName == dayName && $0.isCompleted }
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
                                .font(Typo.body)
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
            .ignoresSafeArea(.keyboard)
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

    private var definition: ProgramDefinition {
        program.definition ?? .delormeClassic
    }

    func findSession(_ dayName: String) -> WorkoutSession? {
        allSessions.first { $0.weekNumber == week && $0.dayName == dayName && $0.isCompleted }
        ?? allSessions.first { $0.weekNumber == week && $0.dayName == dayName }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(weekLabel)
                            .font(Typo.heading)
                        if isCurrentWeek {
                            Text("NOW")
                                .font(.system(size: 10, weight: .heavy))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(theme.accentColor, in: Capsule())
                                .foregroundStyle(.black)
                        }
                    }
                    if definition.cycleLength == 7 && week == 7 {
                        Text("Final Test")
                            .font(Typo.small)
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

    private var weekLabel: String {
        switch week {
        case -1: "Intro 1"
        case 0: "Intro 2"
        default:
            if definition.cycleLength == 7 && week == 7 {
                "Week 7"
            } else {
                "Week \(week)"
            }
        }
    }

    // MARK: - Day Dots

    private var dayDots: some View {
        let dayNames: [String] = {
            if definition.cycleLength == 7 && week == 7 {
                return [definition.days[0].name]
            }
            return definition.days.map(\.name)
        }()
        let progressionGroupCount = 5

        return HStack(spacing: 8) {
            ForEach(dayNames, id: \.self) { dayName in
                let session = findSession(dayName)
                let done = session?.isCompleted == true
                let isPrimaryDay = dayName == definition.days.first?.name
                let exerciseNames = Set((session?.completedSets ?? []).map(\.exerciseName))
                let allHitTarget = done && isPrimaryDay && !exerciseNames.isEmpty && exerciseNames.allSatisfy { name in
                    let max = (session?.completedSets ?? [])
                        .filter { $0.exerciseName == name && $0.isCompleted }
                        .map(\.groupNumber).max() ?? 0
                    return max >= progressionGroupCount
                }
                let shortLabel = definition.days.first(where: { $0.name == dayName })?.shortLabel ?? ""

                VStack(spacing: 3) {
                    Circle()
                        .fill(allHitTarget ? theme.completedColor :
                              done ? theme.accentColor :
                              Color.white.opacity(0.1))
                        .frame(width: 20, height: 20)
                        .overlay {
                            if allHitTarget {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.black)
                            } else if done {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.black)
                            }
                        }
                    Text(shortLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                }
            }
        }
    }

    // MARK: - Expanded Content

    @ViewBuilder
    private var expandedContent: some View {
        let dayNames: [String] = {
            if definition.cycleLength == 7 && week == 7 {
                return [definition.days[0].name]
            }
            return definition.days.map(\.name)
        }()

        VStack(spacing: 12) {
            ForEach(dayNames, id: \.self) { dayName in
                dayRow(dayName)
            }
        }
    }

    private func dayRow(_ dayName: String) -> some View {
        let planned = WorkoutEngine.generateWorkout(
            definition: definition,
            dayName: dayName,
            week: week,
            exercises: program.exercises
        )
        let intensities = WorkoutEngine.intensityLevels(definition: definition, dayName: dayName, week: week)
        let isMultiSet = intensities.count > 1
        let heavyPerExercise = heavyGroupsPerExercise
        let mode = WorkoutEngine.groupCount(
            definition: definition,
            dayName: dayName,
            week: week,
            heavyGroupCount: heavyGroupsForWeek
        )
        let session = findSession(dayName)
        let isDone = session?.isCompleted == true
        let progressionGroupCount = 5

        let exerciseGroups: [(name: String, count: Int)] = isDone && session != nil
            ? planned.map { ex in (name: ex.name, count: session!.fullyCompletedGroupCount(for: ex.name)) }
            : []
        let allHitTarget = isDone && !exerciseGroups.isEmpty && exerciseGroups.allSatisfy { $0.count >= progressionGroupCount }

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(dayName)
                    .font(Typo.bodyEmphasis)
                    .foregroundStyle(isDone ? theme.accentColor : theme.accentColor)

                if allHitTarget {
                    Image(systemName: "checkmark.circle.fill")
                        .font(Typo.caption)
                        .foregroundStyle(theme.completedColor)
                }

                Spacer()

                if isDone {
                    HStack(spacing: 6) {
                        ForEach(exerciseGroups, id: \.name) { eg in
                            Text("\(eg.count)")
                                .font(Typo.small)
                                .foregroundStyle(eg.count >= progressionGroupCount ? theme.completedColor : theme.accentColor)
                        }
                    }
                } else {
                    switch mode {
                    case .max:
                        Label("max \(WorkoutEngine.groupTerm(definition: definition, dayName: dayName, week: week))", systemImage: "flame")
                            .font(Typo.statLabel)
                            .foregroundStyle(theme.accentColor.opacity(0.8))
                    case .fixed(let n):
                        Text(WorkoutEngine.groupTerm(definition: definition, dayName: dayName, week: week, count: n))
                            .font(Typo.statLabel)
                            .foregroundStyle(theme.textSecondary)
                    }
                }
            }

            ForEach(planned, id: \.name) { exercise in
                if isMultiSet {
                    HStack(spacing: 0) {
                        Text(exercise.name)
                            .font(Typo.caption)
                            .foregroundStyle(theme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(exercise.sets, id: \.intensity) { set in
                            Text(set.shortDisplayWeight)
                                .font(.system(.caption, design: .monospaced, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.85))
                                .frame(width: 52, alignment: .trailing)
                        }
                    }
                } else {
                    let slot = definition.days.first(where: { $0.name == dayName })?
                        .exerciseSlots.first(where: { $0.defaultExercise == exercise.name || $0.alternatives.contains(exercise.name) })
                    let reps = slot?.setGroups.first?.sets.first?.reps ?? 5
                    let sets = slot?.setGroups.first?.repeatCount.fixedValue ?? 1

                    HStack {
                        Text(exercise.name)
                            .font(Typo.caption)
                            .foregroundStyle(theme.textSecondary)
                        Spacer()
                        Text("\(exercise.sets.first?.shortDisplayWeight ?? "")  \(reps)×\(sets)")
                            .font(.system(.caption, design: .monospaced, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
            }
        }
        .padding(12)
        .background(theme.backgroundColor.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
    }

    private var heavyGroupsPerExercise: [String: Int] {
        let primaryDayName = definition.days.first?.name ?? "Heavy"
        let session = allSessions.first {
            $0.weekNumber == week && $0.dayName == primaryDayName && $0.isCompleted
        }
        guard let session else { return [:] }
        var result: [String: Int] = [:]
        for exercise in program.exercises {
            result[exercise.name] = session.fullyCompletedGroupCount(for: exercise.name)
        }
        return result
    }

    private var heavyGroupsForWeek: Int? {
        let perExercise = heavyGroupsPerExercise
        guard !perExercise.isEmpty else { return nil }
        return perExercise.values.min()
    }
}
