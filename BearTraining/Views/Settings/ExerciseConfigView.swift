import SwiftUI
import SwiftData

struct ExerciseConfigView: View {
    @Bindable var exercise: Exercise
    @Environment(ThemeManager.self) private var theme

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            List {
                Section("Exercise") {
                    TextField("Name", text: $exercise.name)
                }

                if exercise.type == .weighted {
                    Section("Starting Weight") {
                        HStack {
                            Text("10RM")
                            Spacer()
                            TextField("Weight", value: $exercise.initial10RM, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text(exercise.unit.symbol)
                                .foregroundStyle(theme.textSecondary)
                        }

                        HStack {
                            Text("Weekly Increment")
                            Spacer()
                            TextField("Increment", value: $exercise.weightIncrement, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                            Text(exercise.unit.symbol)
                                .foregroundStyle(theme.textSecondary)
                        }
                    }
                }

                Section("Info") {
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(exercise.type == .bodyweight ? "Bodyweight" : "Weighted")
                            .foregroundStyle(theme.textSecondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
