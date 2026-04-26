import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @Query private var programs: [Program]
    @State private var viewModel = WorkoutViewModel()
    @State private var showingComplete = false
    @State private var lastSessionSummary: SessionSummary?

    private var program: Program? { programs.first }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                if let program {
                    if showingComplete, let summary = lastSessionSummary {
                        workoutCompleteView(summary: summary, program: program)
                    } else if viewModel.isWorkoutActive {
                        WorkoutSessionView(viewModel: viewModel, program: program, onFinish: { summary in
                            lastSessionSummary = summary
                            withAnimation { showingComplete = true }
                        })
                    } else if viewModel.hasWorkoutToday {
                        workoutPreview(program: program)
                    } else {
                        restDayView
                    }
                } else {
                    noProgram
                }
            }
            .navigationTitle(viewModel.isWorkoutActive || showingComplete ? "" : "Workout")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if let program {
                viewModel.prepareWorkout(program: program, modelContext: modelContext)
            }
        }
    }

    private func workoutPreview(program: Program) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 10) {
                    // Day header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Week \(viewModel.weekNumber) · \(WorkoutEngine.suggestedDay(definition: program.definition ?? .delormeClassic, dayName: viewModel.dayName))")
                                .font(Typo.caption)
                                .foregroundStyle(theme.textSecondary)
                            Text(viewModel.dayName)
                                .font(Typo.title)
                        }
                        Spacer()
                    }
                    ForEach(viewModel.plannedExercises, id: \.name) { exercise in
                        let seriesCount = viewModel.groupsPerExerciseCount(exercise.name)
                        let isMax = viewModel.groupModeForExercise(exercise.name) == .max

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(exercise.name)
                                    .font(Typo.heading)
                                Spacer()
                                if isMax {
                                    Label("max series", systemImage: "flame")
                                        .font(Typo.small)
                                        .foregroundStyle(theme.accentColor)
                                } else {
                                    Text("\(seriesCount) series")
                                        .font(Typo.small)
                                        .foregroundStyle(theme.textSecondary)
                                }
                            }

                            ForEach(exercise.sets, id: \.intensity) { set in
                                HStack {
                                    Text(set.intensityLabel)
                                        .font(Typo.small)
                                        .foregroundStyle(theme.textSecondary)
                                        .frame(width: 36, alignment: .leading)
                                    Text(set.displayWeight)
                                        .font(Typo.weightStandard)
                                    if exercise.type == .weighted {
                                        Text(exercise.unit.symbol)
                                            .font(Typo.small)
                                            .foregroundStyle(theme.textSecondary)
                                    }
                                    Spacer()
                                    Text("x\(set.reps)")
                                        .font(Typo.caption)
                                        .foregroundStyle(theme.textSecondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
            }

            // Start button
            Button {
                viewModel.startWorkout(program: program, modelContext: modelContext)
            } label: {
                Text("Start Workout")
                    .font(Typo.heading)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(theme.accentColor, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.black)
            }
            .padding()
        }
    }

    private var restDayView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "trophy.fill")
                .font(.system(size: 56))
                .foregroundStyle(theme.accentColor)
            Text("Program Complete")
                .font(Typo.title)
            Text("You've finished the cycle.\nStart a new one with updated weights.")
                .font(Typo.body)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)

            if let program {
                VStack(spacing: 1) {
                    ForEach(program.exercises.sorted(by: { $0.sortOrder < $1.sortOrder })) { exercise in
                        HStack {
                            Text(exercise.name)
                                .foregroundStyle(theme.textSecondary)
                            Spacer()
                            Text(formatted(exercise.initial10RM))
                                .fontWeight(.semibold)
                            Text(exercise.unit.symbol)
                                .foregroundStyle(theme.textSecondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(theme.cardColor)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    startNewCycle(program: program)
                } label: {
                    Text("Start New Cycle")
                        .font(Typo.heading)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.accentColor, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.black)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func startNewCycle(program: Program) {
        program.currentWeek = program.introCycleEnabled ? -1 : 1
        program.startDate = .now
        try? modelContext.save()
        viewModel.prepareWorkout(program: program, modelContext: modelContext)
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }

    // MARK: - Workout Complete

    private func workoutCompleteView(summary: SessionSummary, program: Program) -> some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(theme.completedColor)
                .padding(.bottom, 20)

            Text("Well done")
                .font(Typo.hero)
                .padding(.bottom, 8)

            Text(summary.dayName)
                .font(Typo.body)
                .foregroundStyle(theme.textSecondary)

            VStack(spacing: 12) {
                HStack(spacing: 24) {
                    statBubble(value: summary.duration, label: "Time")
                    statBubble(value: summary.groupCounts.map(String.init).joined(separator: "/"), label: "Series")
                    statBubble(value: formatted(summary.volume), label: "Volume")
                }
            }
            .padding(.top, 32)

            Spacer()
            Spacer()

            Button {
                withAnimation {
                    showingComplete = false
                    lastSessionSummary = nil
                    viewModel.prepareWorkout(program: program, modelContext: modelContext)
                }
            } label: {
                Text(viewModel.hasWorkoutToday ? "Next Workout →" : "Done")
                    .font(Typo.body)
                    .foregroundStyle(theme.accentColor)
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 28)
    }

    private func statBubble(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Typo.statValue)
            Text(label)
                .font(Typo.statLabel)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
    }

    private var noProgram: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("No program set up yet.")
                .foregroundStyle(theme.textSecondary)
            Spacer()
        }
    }
}
