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

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.allSetsGroupedBySeries(), id: \.series) { group in
                        SeriesCard(
                            seriesNumber: group.series,
                            sets: group.sets,
                            viewModel: viewModel,
                            theme: theme,
                            isCurrentSeries: group.series == viewModel.currentSeriesNumber
                        )
                    }

                    if viewModel.currentSeriesComplete && viewModel.canAddMoreSeries {
                        nextSeriesButton
                    }
                }
                .padding()
            }

            finishButton
        }
        .background(theme.backgroundColor)
        .alert("Finish Workout?", isPresented: $showingFinishConfirm) {
            Button("Finish", role: .destructive) {
                viewModel.finishWorkout(modelContext: modelContext)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Series completed: \(viewModel.currentSeriesNumber)")
        }
    }

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

            if viewModel.seriesMode == .max {
                Text("Series \(viewModel.currentSeriesNumber)")
                    .font(.subheadline.bold())
                    .foregroundStyle(theme.accentColor)
            } else if let target = viewModel.targetSeriesCount {
                Text("\(viewModel.currentSeriesNumber)/\(target)")
                    .font(.subheadline.bold())
                    .foregroundStyle(theme.accentColor)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.caption)
                Text(viewModel.formattedElapsed)
                    .font(.system(.body, design: .monospaced))
            }
            .foregroundStyle(theme.textSecondary)
        }
        .padding()
        .background(theme.cardColor)
    }

    @ViewBuilder
    private var restTimerBanner: some View {
        if viewModel.isRestTimerRunning {
            HStack {
                Image(systemName: "hourglass")
                Text("Rest: \(viewModel.formattedRest)")
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                Spacer()
                Button("Skip") { viewModel.skipRestTimer() }
                    .font(.subheadline.bold())
                    .foregroundStyle(theme.accentColor)
            }
            .padding()
            .background(theme.accentColor.opacity(0.12))
        }
    }

    private var nextSeriesButton: some View {
        Button {
            guard let session = viewModel.activeSession else { return }
            withAnimation { viewModel.addNextSeries(to: session) }
        } label: {
            Label(
                viewModel.seriesMode == .max ? "Start Next Series" : "Next Series",
                systemImage: "plus.circle.fill"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(theme.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(theme.accentColor)
        }
    }

    private var finishButton: some View {
        Button {
            showingFinishConfirm = true
        } label: {
            Text("Finish Workout")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(theme.completedColor, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.black)
        }
        .padding()
    }
}

// MARK: - Series Card

struct SeriesCard: View {
    let seriesNumber: Int
    let sets: [CompletedSet]
    let viewModel: WorkoutViewModel
    let theme: ThemeManager
    let isCurrentSeries: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Series \(seriesNumber)")
                    .font(.subheadline.bold())
                    .foregroundStyle(isCurrentSeries ? theme.accentColor : theme.textSecondary)
                Spacer()
                if allComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(theme.completedColor)
                }
            }

            let exerciseGroups = groupByExercise(sets)
            ForEach(exerciseGroups, id: \.name) { group in
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)

                    ForEach(group.sets) { set in
                        SetRowView(set: set, viewModel: viewModel, theme: theme)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isCurrentSeries ? theme.accentColor.opacity(0.3) : .clear, lineWidth: 1)
                )
        )
        .opacity(allComplete && !isCurrentSeries ? 0.6 : 1)
    }

    private var allComplete: Bool {
        !sets.isEmpty && sets.allSatisfy(\.isCompleted)
    }

    private struct ExerciseGroup: Identifiable {
        let name: String
        let sets: [CompletedSet]
        var id: String { name }
    }

    private func groupByExercise(_ sets: [CompletedSet]) -> [ExerciseGroup] {
        var seen: [String] = []
        var groups: [String: [CompletedSet]] = [:]
        for set in sets {
            if !seen.contains(set.exerciseName) { seen.append(set.exerciseName) }
            groups[set.exerciseName, default: []].append(set)
        }
        return seen.map { ExerciseGroup(name: $0, sets: groups[$0]!) }
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
                Button {
                    isEditing = true
                } label: {
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
