import SwiftUI
import SwiftData

struct WorkoutSessionView: View {
    @Bindable var viewModel: WorkoutViewModel
    let program: Program
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @State private var showingFinishConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            sessionHeader
            restTimerBanner

            if let exercise = viewModel.currentExercise {
                exerciseView(exercise)
            }

            bottomBar
        }
        .background(theme.backgroundColor)
        .alert("Finish Workout?", isPresented: $showingFinishConfirm) {
            Button("Finish", role: .destructive) {
                viewModel.finishWorkout(modelContext: modelContext)
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Header

    private var sessionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Week \(viewModel.weekNumber) — \(viewModel.dayType.rawValue)")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                if let exercise = viewModel.currentExercise {
                    Text(exercise.name)
                        .font(.title3.bold())
                }
            }

            Spacer()

            exerciseProgress

            Spacer().frame(width: 16)

            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.caption)
                Text(viewModel.formattedElapsed)
                    .font(.system(.subheadline, design: .monospaced))
            }
            .foregroundStyle(theme.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.cardColor)
    }

    private var exerciseProgress: some View {
        HStack(spacing: 6) {
            ForEach(viewModel.plannedExercises.indices, id: \.self) { i in
                Capsule()
                    .fill(i < viewModel.currentExerciseIndex ? theme.completedColor :
                          i == viewModel.currentExerciseIndex ? theme.accentColor :
                          Color.white.opacity(0.15))
                    .frame(width: i == viewModel.currentExerciseIndex ? 20 : 8, height: 6)
            }
        }
    }

    // MARK: - Rest Timer

    @ViewBuilder
    private var restTimerBanner: some View {
        if viewModel.isRestTimerRunning {
            HStack {
                Image(systemName: "hourglass")
                Text(viewModel.formattedRest)
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                Spacer()
                Text(viewModel.restTimerRemaining > 120 ? "Series rest" : "Set rest")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                Button("Skip") { viewModel.skipRestTimer() }
                    .font(.subheadline.bold())
                    .foregroundStyle(theme.accentColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(theme.accentColor.opacity(0.12))
        }
    }

    // MARK: - Exercise View

    private func exerciseView(_ exercise: PlannedSeriesExercise) -> some View {
        let seriesGroups = viewModel.setsGroupedBySeries(for: exercise.name)
        let mode = viewModel.seriesModeForExercise(exercise.name)
        let currentSeries = viewModel.currentSeriesForExercise(exercise.name)
        let allCurrentDone = viewModel.allSetsCompleteForCurrentSeries(exerciseName: exercise.name)

        return ScrollView {
            VStack(spacing: 12) {
                // Series mode label
                HStack {
                    switch mode {
                    case .max:
                        Label("Series \(currentSeries) — go until you can't", systemImage: "flame")
                            .font(.subheadline)
                            .foregroundStyle(theme.accentColor)
                    case .fixed(let n):
                        Text("Series \(currentSeries) of \(n)")
                            .font(.subheadline)
                            .foregroundStyle(theme.textSecondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)

                // Series cards
                ForEach(seriesGroups, id: \.series) { group in
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
                                    .strokeBorder(isCurrent ? theme.accentColor.opacity(0.3) : .clear, lineWidth: 1)
                            )
                    )
                    .opacity(allDone && !isCurrent ? 0.5 : 1)
                }

                // Action buttons
                if allCurrentDone {
                    if viewModel.canAddMoreSeries(for: exercise.name) {
                        Button {
                            withAnimation { viewModel.addAnotherSeries() }
                        } label: {
                            Label(
                                mode == .max ? "Start Next Series" : "Next Series",
                                systemImage: "plus.circle.fill"
                            )
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(theme.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(theme.accentColor)
                        }
                    }

                    if !viewModel.isLastExercise {
                        Button {
                            withAnimation { viewModel.moveToNextExercise() }
                        } label: {
                            Label("Move to \(viewModel.plannedExercises[viewModel.currentExerciseIndex + 1].name)", systemImage: "arrow.right.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(theme.completedColor, in: RoundedRectangle(cornerRadius: 14))
                                .foregroundStyle(.black)
                        }
                    }

                    if mode == .max || viewModel.isLastExercise {
                        Button {
                            if viewModel.isLastExercise {
                                showingFinishConfirm = true
                            } else {
                                withAnimation { viewModel.moveToNextExercise() }
                            }
                        } label: {
                            if viewModel.isLastExercise {
                                Label("Finish Workout", systemImage: "flag.checkered")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(theme.completedColor, in: RoundedRectangle(cornerRadius: 14))
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button { showingFinishConfirm = true } label: {
                Text("End Early")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer()
            if let name = viewModel.currentExercise?.name {
                let count = viewModel.currentSeriesForExercise(name)
                Text("\(count) series done")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.cardColor)
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
