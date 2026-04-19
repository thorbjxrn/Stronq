import SwiftUI
import SwiftData

struct ExerciseConfigView: View {
    @Bindable var exercise: Exercise
    @Environment(ThemeManager.self) private var theme
    @Environment(PurchaseManager.self) private var purchaseManager
    @FocusState private var isEditing: Bool
    @State private var showingPaywall = false

    private var alternatives: [ExerciseAlternative] {
        ExerciseAlternative.alternatives(for: exercise.name)
    }

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
                                    isEditing = false
                                    let step = exercise.weightIncrement > 0 ? exercise.weightIncrement : 2.5
                                    if exercise.initial10RM > step {
                                        exercise.initial10RM -= step
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(theme.textSecondary)
                                }
                                .buttonStyle(.borderless)

                                TextField("", value: $exercise.initial10RM, format: .number)
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.decimalPad)
                                    .focused($isEditing)
                                    .frame(minWidth: 80)

                                Button {
                                    isEditing = false
                                    let step = exercise.weightIncrement > 0 ? exercise.weightIncrement : 2.5
                                    exercise.initial10RM += step
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(theme.accentColor)
                                }
                                .buttonStyle(.borderless)

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

                if !alternatives.isEmpty {
                    Section {
                        ForEach(alternatives) { alt in
                            Button {
                                if purchaseManager.isPremium {
                                    exercise.name = alt.name
                                } else {
                                    showingPaywall = true
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: alt.icon)
                                        .foregroundStyle(theme.accentColor)
                                        .frame(width: 24)
                                    Text(alt.name)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    if !purchaseManager.isPremium {
                                        Image(systemName: "lock.fill")
                                            .font(.caption)
                                            .foregroundStyle(theme.textSecondary)
                                    }
                                }
                            }
                            .listRowBackground(theme.cardColor)
                        }
                    } header: {
                        Text("Swap Exercise")
                    } footer: {
                        Text("Same weight and increment. Adjust above if needed.")
                            .font(.caption2)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isEditing = false }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
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
