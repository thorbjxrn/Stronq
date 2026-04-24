import SwiftUI
import SwiftData

struct WorkoutSessionView: View {
    var viewModel: WorkoutViewModel
    let program: Program
    var onFinish: ((SessionSummary) -> Void)?
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @State private var showingFinishConfirm = false
    @State private var selectedExercise: Int = 0

    private var allExercisesDone: Bool {
        viewModel.plannedExercises.allSatisfy { viewModel.isExerciseDone($0.name) }
    }

    var body: some View {
        VStack(spacing: 0) {
            sessionHeader
            exerciseTabs
            restTimerBanner

            TabView(selection: $selectedExercise) {
                ForEach(viewModel.plannedExercises.indices, id: \.self) { index in
                    exercisePage(viewModel.plannedExercises[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            bottomBar
        }
        .background(theme.backgroundColor)
    }

    // MARK: - Header

    private var sessionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Week \(viewModel.weekNumber)")
                    .font(Typo.caption)
                    .foregroundStyle(theme.textSecondary)
                Text(viewModel.dayType.rawValue)
                    .font(Typo.heading)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(Typo.caption)
                Text(viewModel.formattedElapsed)
                    .font(Typo.timerCompact)
            }
            .foregroundStyle(theme.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(theme.cardColor)
    }

    // MARK: - Exercise Tabs

    private var exerciseTabs: some View {
        HStack(spacing: 2) {
            ForEach(viewModel.plannedExercises.indices, id: \.self) { index in
                let exercise = viewModel.plannedExercises[index]
                let isSelected = selectedExercise == index
                let isDone = viewModel.isExerciseDone(exercise.name)
                let seriesCount = viewModel.currentSeriesForExercise(exercise.name)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedExercise = index }
                } label: {
                    HStack(spacing: 6) {
                        if isDone {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(theme.completedColor)
                        }
                        VStack(spacing: 2) {
                            Text(exercise.name)
                                .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            if seriesCount > 0 {
                                Text("\(seriesCount) series")
                                    .font(Typo.statLabel)
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? theme.accentColor.opacity(0.15) : .clear)
                    )
                }
                .foregroundStyle(isSelected ? theme.accentColor : isDone ? theme.completedColor : theme.textPrimary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Rest Timer

    @ViewBuilder
    private var restTimerBanner: some View {
        if viewModel.isRestTimerRunning {
            HStack {
                Text(viewModel.formattedRest)
                    .font(Typo.timer)
                    .foregroundStyle(theme.accentColor)
                Spacer()
                Button("Skip") { viewModel.skipRestTimer() }
                    .font(Typo.bodyEmphasis)
                    .foregroundStyle(theme.accentColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(theme.accentColor.opacity(0.08))
        }
    }

    // MARK: - Exercise Page

    private func exercisePage(_ exercise: PlannedSeriesExercise) -> some View {
        let groups = viewModel.setsGroupedBySeries(for: exercise.name)
        let mode = viewModel.seriesModeForExercise(exercise.name)
        let lastSeriesDone = viewModel.allSetsCompleteForCurrentSeries(exerciseName: exercise.name)
        let isDone = viewModel.isExerciseDone(exercise.name)
        let currentSeries = viewModel.currentSeriesForExercise(exercise.name)

        return ScrollView {
            VStack(spacing: 12) {
                // Mode label
                HStack {
                    switch mode {
                    case .max:
                        Label("Max series", systemImage: "flame")
                            .font(Typo.caption)
                            .foregroundStyle(theme.accentColor)
                    case .fixed(let n):
                        Text("\(currentSeries) of \(n) series")
                            .font(Typo.caption)
                            .foregroundStyle(theme.textSecondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)

                // Series cards
                ForEach(groups, id: \.series) { group in
                    seriesCard(group: group, exerciseName: exercise.name)
                }

                if isDone {
                    doneLabel(exercise.name, seriesCount: currentSeries)
                } else if mode == .max && lastSeriesDone {
                    VStack(spacing: 10) {
                        Button {
                            withAnimation { viewModel.addAnotherSeriesForExercise(exercise.name) }
                        } label: {
                            Label("Add Series", systemImage: "plus.circle.fill")
                                .font(Typo.bodyEmphasis)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(theme.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(theme.accentColor)
                        }

                        Button {
                            withAnimation {
                                viewModel.markExerciseDone(exercise.name)
                                if let nextIndex = viewModel.plannedExercises.firstIndex(where: { !viewModel.isExerciseDone($0.name) }) {
                                    selectedExercise = nextIndex
                                }
                            }
                        } label: {
                            Label("Done — \(viewModel.completedSeriesCount(for: exercise.name)) series", systemImage: "checkmark")
                                .font(Typo.bodyEmphasis)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(theme.completedColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(theme.completedColor)
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    private func seriesCard(group: (series: Int, sets: [CompletedSet]), exerciseName: String) -> some View {
        let allDone = group.sets.allSatisfy(\.isCompleted)
        let isCurrent = !allDone && isFirstIncompleteSeries(group.series, exerciseName: exerciseName)

        return VStack(spacing: 6) {
            HStack {
                Text("Series \(group.series)")
                    .font(Typo.captionEmphasis)
                    .foregroundStyle(isCurrent ? theme.accentColor : theme.textSecondary)
                Spacer()
                if allDone {
                    Image(systemName: "checkmark.circle.fill")
                        .font(Typo.caption)
                        .foregroundStyle(theme.completedColor)
                }
            }

            ForEach(group.sets) { set in
                    let exerciseUnit = viewModel.plannedExercises.first(where: { $0.name == exerciseName })?.unit ?? .kg
                    SetRowView(set: set, viewModel: viewModel, theme: theme, unit: exerciseUnit)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isCurrent && !allDone ? theme.accentColor.opacity(0.3) : .clear, lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            if allDone {
                for set in group.sets where set.isCompleted {
                    viewModel.uncompleteSet(set)
                }
            } else {
                let incompleteSets = group.sets.filter { !$0.isCompleted }
                for set in incompleteSets {
                    set.isCompleted = true
                    set.completedAt = .now
                }
                if let lastSet = incompleteSets.last {
                    viewModel.completeSet(lastSet)
                } else {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }
        .onTapGesture(count: 1) {
            if let nextSet = group.sets.first(where: { !$0.isCompleted }) {
                viewModel.completeSet(nextSet)
            }
        }
        .opacity(allDone && !isCurrent ? 0.5 : 1)
    }



    private func doneLabel(_ name: String, seriesCount: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(theme.completedColor)
            Text("\(name) done — \(seriesCount) series")
                .foregroundStyle(theme.textSecondary)
        }
        .font(Typo.body)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(theme.completedColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private func isFirstIncompleteSeries(_ series: Int, exerciseName: String) -> Bool {
        let groups = viewModel.setsGroupedBySeries(for: exerciseName)
        for group in groups {
            if !group.sets.allSatisfy(\.isCompleted) {
                return group.series == series
            }
        }
        return false
    }

    private func finishAndShow() {
        let elapsed = viewModel.elapsedTime
        let volume = viewModel.activeSession?.totalVolume ?? 0
        let day = viewModel.dayType
        let series = program.exercises
            .sorted(by: { $0.sortOrder < $1.sortOrder })
            .map { viewModel.completedSeriesCount(for: $0.name) }

        viewModel.finishWorkout(program: program, modelContext: modelContext)

        if let onFinish {
            onFinish(SessionSummary(
                dayType: day,
                elapsed: elapsed,
                volume: volume,
                seriesCounts: series
            ))
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        Group {
            if allExercisesDone {
                Button {
                    finishAndShow()
                } label: {
                    Label("Finish Workout", systemImage: "flag.checkered")
                        .font(Typo.heading)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.completedColor, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.black)
                }
                .padding(16)
            } else {
                HStack {
                    Button { showingFinishConfirm = true } label: {
                        Text("End Early")
                            .font(Typo.body)
                            .foregroundStyle(theme.textSecondary)
                    }
                    .alert("End workout early?", isPresented: $showingFinishConfirm) {
                        Button("Save & End") {
                            finishAndShow()
                        }
                        Button("Discard", role: .destructive) {
                            viewModel.cancelWorkout(program: program, modelContext: modelContext)
                        }
                        Button("Keep Training", role: .cancel) {}
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(theme.cardColor)
            }
        }
    }
}

// MARK: - Set Row

struct SetRowView: View {
    @Bindable var set: CompletedSet
    let viewModel: WorkoutViewModel
    let theme: ThemeManager
    var unit: WeightUnit = .kg
    @State private var isEditing = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                if set.isCompleted {
                    viewModel.uncompleteSet(set)
                } else {
                    viewModel.completeSet(set)
                }
                isEditing = false
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(set.isCompleted ? theme.completedColor : theme.textSecondary.opacity(0.4))
            }

            Text(intensityLabel)
                .font(Typo.small)
                .foregroundStyle(theme.textSecondary)
                .frame(width: 36)

            Text(set.displayWeight)
                .font(Typo.weightStandard)
            if set.pushUpVariant == nil {
                Text(unit.symbol)
                    .font(Typo.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer()

            if isEditing {
                Stepper("", value: $set.actualReps, in: 0...25)
                    .labelsHidden()
                    .fixedSize()
                Text("\(set.actualReps)")
                    .font(Typo.bodyEmphasis)
            } else {
                Button { isEditing = true } label: {
                    Text("x\(set.actualReps)")
                        .font(Typo.body)
                        .foregroundStyle(set.actualReps != set.targetReps ? .white : theme.textSecondary)
                }
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture {
            if isEditing { isEditing = false }
        }
    }

    private var intensityLabel: String {
        switch set.intensity {
        case 0.5: "50%"
        case 0.75: "75%"
        case 1.0: "100%"
        default: "\(Int(set.intensity * 100))%"
        }
    }
}
