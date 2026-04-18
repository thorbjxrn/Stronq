import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @Query private var programs: [Program]
    @State private var viewModel = WorkoutViewModel()
    @State private var showingSession = false

    private var program: Program? { programs.first }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                if let program {
                    if viewModel.isWorkoutActive {
                        WorkoutSessionView(viewModel: viewModel, program: program)
                    } else if let planned = viewModel.plannedWorkout {
                        workoutPreview(planned, program: program)
                    } else {
                        restDayView(program: program)
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
                viewModel.generateTodayWorkout(program: program)
            }
        }
    }

    private func workoutPreview(_ workout: PlannedWorkout, program: Program) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                weekDayHeader(workout)

                ForEach(workout.exercises, id: \.name) { exercise in
                    ExercisePreviewCard(exercise: exercise, theme: theme)
                }

                Button {
                    viewModel.startWorkout(program: program, modelContext: modelContext)
                } label: {
                    Text("Start Workout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.accentColor)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }

    private func weekDayHeader(_ workout: PlannedWorkout) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Week \(workout.week)")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                Text(workout.dayType.rawValue)
                    .font(.title2.bold())
            }
            Spacer()
            Text(Date.now, style: .date)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
        }
        .padding()
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
    }

    private func restDayView(program: Program) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bed.double.fill")
                .font(.system(size: 50))
                .foregroundStyle(theme.textSecondary)
            Text("Rest Day")
                .font(.title2.bold())
            Text("No workout scheduled today.\nYour next session is on the next training day.")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
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

struct ExercisePreviewCard: View {
    let exercise: PlannedExercise
    let theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                Spacer()
                Text("\(exercise.seriesCount) series")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            ForEach(exercise.sets, id: \.intensity) { set in
                HStack {
                    Text(set.intensityLabel)
                        .font(.caption)
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
                    Text("\(set.reps) reps")
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                }
            }
        }
        .padding()
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
    }
}
