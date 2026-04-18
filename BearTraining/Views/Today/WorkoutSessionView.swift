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
                if let session = viewModel.activeSession {
                    LazyVStack(spacing: 16) {
                        ForEach(exerciseNames(from: session), id: \.self) { name in
                            ExerciseSessionCard(
                                exerciseName: name,
                                sets: session.setsForExercise(name),
                                viewModel: viewModel,
                                theme: theme
                            )
                        }
                    }
                    .padding()
                }
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
            Text("You've completed \(viewModel.activeSession?.completedSetCount ?? 0) of \(viewModel.activeSession?.totalSetCount ?? 0) sets.")
        }
    }

    private var sessionHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                if let planned = viewModel.plannedWorkout {
                    Text("Week \(planned.week) — \(planned.dayType.rawValue)")
                        .font(.subheadline.bold())
                }
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.caption)
                Text(viewModel.formattedElapsed)
                    .font(.system(.body, design: .monospaced))
            }
            .foregroundStyle(theme.accentColor)
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
                Button("Skip") {
                    viewModel.skipRestTimer()
                }
                .font(.subheadline.bold())
                .foregroundStyle(theme.accentColor)
            }
            .padding()
            .background(theme.accentColor.opacity(0.15))
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut, value: viewModel.isRestTimerRunning)
        }
    }

    private var finishButton: some View {
        Button {
            showingFinishConfirm = true
        } label: {
            Text("Finish Workout")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.completedColor)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding()
    }

    private func exerciseNames(from session: WorkoutSession) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for set in session.completedSets.sorted(by: { ($0.exerciseName, $0.seriesNumber, $0.setNumber) < ($1.exerciseName, $1.seriesNumber, $1.setNumber) }) {
            if seen.insert(set.exerciseName).inserted {
                result.append(set.exerciseName)
            }
        }
        return result
    }
}

struct ExerciseSessionCard: View {
    let exerciseName: String
    let sets: [CompletedSet]
    let viewModel: WorkoutViewModel
    let theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exerciseName)
                .font(.headline)
                .padding(.bottom, 4)

            ForEach(sets) { set in
                SetRowView(set: set, viewModel: viewModel, theme: theme)
            }
        }
        .padding()
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
    }
}

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
                    .foregroundStyle(set.isCompleted ? theme.completedColor : theme.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("S\(set.seriesNumber + 1) — \(intensityLabel)")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                Text(set.displayWeight)
                    .font(.system(.title3, design: .rounded, weight: .bold))
            }

            Spacer()

            if isEditing {
                HStack(spacing: 8) {
                    Stepper("", value: $set.actualReps, in: 0...10)
                        .labelsHidden()
                        .fixedSize()
                    Text("\(set.actualReps)r")
                        .font(.system(.body, design: .monospaced))
                }
            } else {
                Button {
                    isEditing = true
                } label: {
                    Text("\(set.targetReps) reps")
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(set.isCompleted ? 0.7 : 1)
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
