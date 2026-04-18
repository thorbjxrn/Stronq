import SwiftUI
import SwiftData

struct ExerciseConfigView: View {
    @Bindable var exercise: Exercise
    @Environment(ThemeManager.self) private var theme

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            List {
                if exercise.type == .weighted {
                    Section {
                        VStack(spacing: 16) {
                            Text("10 Rep Max")
                                .font(.caption.bold())
                                .foregroundStyle(theme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 16) {
                                Button {
                                    let step = exercise.weightIncrement > 0 ? exercise.weightIncrement : 2.5
                                    if exercise.initial10RM > step {
                                        exercise.initial10RM -= step
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(theme.textSecondary)
                                }

                                Text(formatted(exercise.initial10RM))
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .frame(minWidth: 80)

                                Button {
                                    let step = exercise.weightIncrement > 0 ? exercise.weightIncrement : 2.5
                                    exercise.initial10RM += step
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(theme.accentColor)
                                }

                                Text(exercise.unit.symbol)
                                    .font(.title3)
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(theme.cardColor)
                    }

                    Section("Increment Per Cycle") {
                        HStack {
                            Text("Add when 5 series completed")
                                .font(.subheadline)
                                .foregroundStyle(theme.textSecondary)
                            Spacer()
                            TextField("", value: $exercise.weightIncrement, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 50)
                                .font(.system(.body, design: .rounded, weight: .bold))
                            Text(exercise.unit.symbol)
                                .foregroundStyle(theme.textSecondary)
                        }
                        .listRowBackground(theme.cardColor)
                    }

                    Section("Current Workout Weights") {
                        weightPreviewRow("50%", weight: exercise.initial10RM * 0.5)
                        weightPreviewRow("75%", weight: exercise.initial10RM * 0.75)
                        weightPreviewRow("100%", weight: exercise.initial10RM)
                    }
                }

                Section {
                    TextField("Exercise Name", text: $exercise.name)
                        .listRowBackground(theme.cardColor)
                } header: {
                    Text("Name")
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func weightPreviewRow(_ label: String, weight: Double) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .frame(width: 44, alignment: .leading)
            Text(formatted(weight))
                .font(.system(.body, design: .rounded, weight: .semibold))
            Text(exercise.unit.symbol)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
            Spacer()
            Text("x 5 reps")
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
        }
        .listRowBackground(theme.cardColor)
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}
