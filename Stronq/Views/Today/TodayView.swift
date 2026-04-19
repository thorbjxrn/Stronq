import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @Query private var programs: [Program]
    @State private var viewModel = WorkoutViewModel()

    private var program: Program? { programs.first }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                if let program {
                    if viewModel.isWorkoutActive {
                        WorkoutSessionView(viewModel: viewModel, program: program)
                    } else if viewModel.hasWorkoutToday {
                        workoutPreview(program: program)
                    } else {
                        restDayView
                    }
                } else {
                    noProgram
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if let program {
                viewModel.prepareWorkout(program: program)
            }
        }
    }

    private func workoutPreview(program: Program) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Day header
                VStack(spacing: 6) {
                    Text("Week \(viewModel.weekNumber)")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                    Text(viewModel.dayType.rawValue)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text(DeLormeEngine.suggestedDay(for: viewModel.dayType))
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                .padding(.top, 8)

                // Series info
                HStack {
                    Image(systemName: viewModel.seriesMode == .max ? "flame" : "arrow.triangle.2.circlepath")
                        .foregroundStyle(theme.accentColor)
                    switch viewModel.seriesMode {
                    case .max:
                        Text("As many series as possible")
                    case .fixed(let n):
                        Text("\(n) series")
                    }
                    Spacer()
                }
                .font(.subheadline)
                .padding(14)
                .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))

                // Exercise preview
                ForEach(viewModel.plannedExercises, id: \.name) { exercise in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(exercise.name)
                            .font(.headline)

                        ForEach(exercise.sets, id: \.intensity) { set in
                            HStack {
                                Text(set.intensityLabel)
                                    .font(.caption.bold())
                                    .foregroundStyle(theme.textSecondary)
                                    .frame(width: 40, alignment: .leading)
                                Text(set.displayWeight)
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                if exercise.type == .weighted {
                                    Text(exercise.unit.symbol)
                                        .font(.caption)
                                        .foregroundStyle(theme.textSecondary)
                                }
                                Spacer()
                                Text("x5")
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                    }
                    .padding()
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
        viewModel.prepareWorkout(program: program)
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
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
