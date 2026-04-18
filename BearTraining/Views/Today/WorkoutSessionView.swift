import SwiftUI
import SwiftData

struct WorkoutSessionView: View {
    @Bindable var viewModel: WorkoutViewModel
    let program: Program
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @State private var showingFinishConfirm = false
    @State private var selectedExercise: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            sessionHeader
            exercisePicker
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
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                Text(viewModel.dayType.rawValue)
                    .font(.headline)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.caption)
                Text(viewModel.formattedElapsed)
                    .font(.system(.subheadline, design: .monospaced))
            }
            .foregroundStyle(theme.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(theme.cardColor)
    }

    // MARK: - Exercise Picker

    private var exercisePicker: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.plannedExercises.indices, id: \.self) { index in
                let exercise = viewModel.plannedExercises[index]
                let isSelected = selectedExercise == index
                let isDone = viewModel.isExerciseDone(exercise.name)
                let seriesCount = viewModel.currentSeriesForExercise(exercise.name)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedExercise = index }
                } label: {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            if isDone {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(theme.completedColor)
                            }
                            Text(exercise.name)
                                .font(.subheadline.weight(isSelected ? .bold : .regular))
                                .lineLimit(1)
                        }
                        if seriesCount > 0 {
                            Text("\(seriesCount) series")
                                .font(.caption2)
                                .foregroundStyle(theme.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isSelected ? theme.accentColor.opacity(0.12) : .clear)
                }
                .foregroundStyle(isSelected ? theme.accentColor : isDone ? theme.completedColor : .white)
            }
        }
        .background(theme.cardColor.opacity(0.5))
    }

    // MARK: - Rest Timer

    @ViewBuilder
    private var restTimerBanner: some View {
        if viewModel.isRestTimerRunning {
            HStack {
                Text(viewModel.formattedRest)
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundStyle(theme.accentColor)
                Spacer()
                Button("Skip") { viewModel.skipRestTimer() }
                    .font(.subheadline.bold())
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
        let currentSeries = viewModel.currentSeriesForExercise(exercise.name)
        let lastSeriesDone = viewModel.allSetsCompleteForCurrentSeries(exerciseName: exercise.name)
        let isDone = viewModel.isExerciseDone(exercise.name)

        return ScrollView {
            VStack(spacing: 12) {
                ForEach(groups, id: \.series) { group in
                    let isCurrent = group.series == currentSeries
                    let allDone = group.sets.allSatisfy(\.isCompleted)

                    VStack(spacing: 6) {
                        HStack {
                            Text("Series \(group.series)")
                                .font(.caption.bold())
                                .foregroundStyle(isCurrent ? theme.accentColor : theme.textSecondary)
                            Spacer()
                            if allDone {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(theme.completedColor)
                            }
                        }

                        ForEach(group.sets) { set in
                            SetRowView(set: set, viewModel: viewModel, theme: theme)
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
                    .opacity(allDone && !isCurrent ? 0.5 : 1)
                }

                if lastSeriesDone && !isDone {
                    HStack(spacing: 12) {
                        if viewModel.canAddMoreSeries(for: exercise.name) {
                            Button {
                                withAnimation { viewModel.addAnotherSeries() }
                            } label: {
                                Label("Another Series", systemImage: "plus.circle.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(theme.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(theme.accentColor)
                            }
                        }

                        Button {
                            withAnimation { viewModel.markExerciseDone(exercise.name) }
                        } label: {
                            Label("Done", systemImage: "checkmark")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(theme.completedColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(theme.completedColor)
                        }
                    }
                }

                if isDone {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(theme.completedColor)
                        Text("\(exercise.name) done — \(currentSeries) series")
                            .foregroundStyle(theme.textSecondary)
                    }
                    .font(.subheadline)
                    .padding(.vertical, 8)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        let allDone = viewModel.plannedExercises.allSatisfy {
            viewModel.isExerciseDone($0.name)
        }

        return Group {
            if allDone {
                Button {
                    viewModel.finishWorkout(modelContext: modelContext)
                } label: {
                    Label("Finish Workout", systemImage: "flag.checkered")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.completedColor, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else {
                HStack {
                    Button {
                        showingFinishConfirm = true
                    } label: {
                        Text("End Early")
                            .font(.subheadline)
                            .foregroundStyle(theme.textSecondary)
                    }
                    .alert("End workout early?", isPresented: $showingFinishConfirm) {
                        Button("End Workout", role: .destructive) {
                            viewModel.finishWorkout(modelContext: modelContext)
                        }
                        Button("Cancel", role: .cancel) {}
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
    @State private var isEditing = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                if set.isCompleted {
                    viewModel.uncompleteSet(set)
                } else {
                    viewModel.completeSet(set)
                }
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(set.isCompleted ? theme.completedColor : Color.white.opacity(0.2))
            }

            Text(intensityLabel)
                .font(.caption2.bold())
                .foregroundStyle(theme.textSecondary)
                .frame(width: 36)

            Text(set.displayWeight)
                .font(.system(.title3, design: .rounded, weight: .bold))

            Spacer()

            if isEditing {
                Stepper("", value: $set.actualReps, in: 0...10)
                    .labelsHidden()
                    .fixedSize()
                Text("\(set.actualReps)")
                    .font(.system(.body, design: .monospaced, weight: .bold))
            } else {
                Button { isEditing = true } label: {
                    Text("x\(set.targetReps)")
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                }
            }
        }
        .padding(.vertical, 2)
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
