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
            .navigationBarHidden(true)
        }
        .onAppear {
            if let program {
                viewModel.prepareWorkout(program: program, modelContext: modelContext)
            }
        }
    }

    @State private var showingSeriesInfo = false

    private func workoutPreview(program: Program) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                // Day header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Week \(viewModel.weekNumber) · \(DeLormeEngine.suggestedDay(for: viewModel.dayType))")
                            .font(.caption)
                            .foregroundStyle(theme.textSecondary)
                        Text(viewModel.dayType.rawValue)
                            .font(.title2.bold())
                    }
                    Spacer()
                    // Series info
                    HStack(spacing: 4) {
                        if viewModel.seriesMode == .max {
                            Image(systemName: "flame")
                                .foregroundStyle(theme.accentColor)
                            Text("Max series")
                        } else {
                            let counts = viewModel.plannedExercises.map { ex in
                                viewModel.seriesPerExerciseCount(ex.name)
                            }
                            if Set(counts).count == 1 {
                                Text("\(counts.first ?? 5) series")
                            } else {
                                Text(counts.map(String.init).joined(separator: "/") + " series")
                            }
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)

                    Button {
                        showingSeriesInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(theme.accentColor)
                    }
                }
                .padding(.top, 8)

                // Exercise preview
                ForEach(viewModel.plannedExercises, id: \.name) { exercise in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(exercise.name)
                            .font(.subheadline.bold())

                        ForEach(exercise.sets, id: \.intensity) { set in
                            HStack {
                                Text(set.intensityLabel)
                                    .font(.caption2.bold())
                                    .foregroundStyle(theme.textSecondary)
                                    .frame(width: 36, alignment: .leading)
                                Text(set.displayWeight)
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                if exercise.type == .weighted {
                                    Text(exercise.unit.symbol)
                                        .font(.caption2)
                                        .foregroundStyle(theme.textSecondary)
                                }
                                Spacer()
                                Text("x5")
                                    .font(.caption)
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
                }

                // Start button
                Button {
                    viewModel.startWorkout(program: program, modelContext: modelContext)
                } label: {
                    Text("Start Workout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.accentColor, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.black)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .alert("What's a series?", isPresented: $showingSeriesInfo) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text("A series is one round of all your sets (50% → 75% → 100%). On Heavy day, do as many series as you can. When you hit 5 full series, your weights go up.")
        }
    }

    private var restDayView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "trophy.fill")
                .font(.system(size: 56))
                .foregroundStyle(theme.accentColor)
            Text("Program Complete")
                .font(.title2.bold())
            Text("You've finished the cycle.\nStart a new one with updated weights.")
                .font(.subheadline)
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
                        .font(.headline)
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
                .font(.system(size: 32, weight: .bold))
                .padding(.bottom, 8)

            Text(summary.dayType.rawValue)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)

            VStack(spacing: 12) {
                HStack(spacing: 24) {
                    statBubble(value: summary.duration, label: "Time")
                    statBubble(value: summary.seriesCounts.map(String.init).joined(separator: "/"), label: "Series")
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
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.accentColor)
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 28)
    }

    private func statBubble(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
            Text(label)
                .font(.caption2)
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
