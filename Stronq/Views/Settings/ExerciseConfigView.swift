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
                                .font(Typo.captionEmphasis)
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
                                        .font(Typo.stepperButton)
                                        .foregroundStyle(theme.textSecondary)
                                }
                                .buttonStyle(.borderless)

                                TextField("", value: $exercise.initial10RM, format: .number)
                                    .font(Typo.weightLarge)
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
                                        .font(Typo.stepperButton)
                                        .foregroundStyle(theme.accentColor)
                                }
                                .buttonStyle(.borderless)

                                Text(exercise.unit.symbol)
                                    .font(Typo.body)
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(theme.cardColor)
                    }

                    Section("Increment Per Cycle") {
                        HStack {
                            Text("Add when 5 series completed")
                                .font(Typo.body)
                                .foregroundStyle(theme.textSecondary)
                            Spacer()
                            TextField("", value: $exercise.weightIncrement, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 50)
                                .font(Typo.weightStandard)
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

                if exercise.type == .bodyweight {
                    Section("Difficulty") {
                        HStack(spacing: 6) {
                            ForEach(PushUpVariant.selectableMaxLevels, id: \.variant) { level in
                                let isSelected = exercise.startingPushUpVariant == level.variant
                                Button {
                                    exercise.startingPushUpVariant = level.variant
                                } label: {
                                    Text(level.label)
                                        .font(Typo.small)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            isSelected ? theme.accentColor : Color.white.opacity(0.08),
                                            in: RoundedRectangle(cornerRadius: 8)
                                        )
                                        .foregroundStyle(isSelected ? .black : theme.textSecondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .listRowBackground(theme.cardColor)

                        Text(PushUpVariant.progressionLabel(for: exercise.startingPushUpVariant))
                            .font(Typo.caption)
                            .foregroundStyle(theme.accentColor)
                            .listRowBackground(theme.cardColor)
                    }
                }

                if !alternatives.isEmpty {
                    Section {
                        ForEach(alternatives) { alt in
                            Button {
                                if alt.isFree || purchaseManager.isPremium {
                                    exercise.name = alt.name
                                    if alt.isWeighted && exercise.type == .bodyweight {
                                        exercise.type = .weighted
                                        exercise.initial10RM = alt.defaultRM
                                        exercise.weightIncrement = alt.defaultIncrement
                                        exercise.pushUpStartLevel = nil
                                    } else if !alt.isWeighted && exercise.type == .weighted {
                                        exercise.type = .bodyweight
                                        exercise.initial10RM = 0
                                        exercise.weightIncrement = 0
                                        exercise.startingPushUpVariant = .oneArm
                                    }
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
                                    if !alt.isFree && !purchaseManager.isPremium {
                                        Image(systemName: "lock.fill")
                                            .font(Typo.caption)
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
                            .font(Typo.small)
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
                .font(Typo.body)
                .foregroundStyle(theme.textSecondary)
                .frame(width: 44, alignment: .leading)
            Text(formatted(weight))
                .font(Typo.weightStandard)
            Text(exercise.unit.symbol)
                .font(Typo.caption)
                .foregroundStyle(theme.textSecondary)
            Spacer()
            Text("x 5 reps")
                .font(Typo.caption)
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
