import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @State private var step = 0
    @State private var unit: WeightUnit = .kg
    @State private var includeIntro = true
    @State private var pulldownRM: Double = 25
    @State private var zercherRM: Double = 45
    @State private var pushUpLevel: PushUpVariant = .regular
    @State private var bodyweight: String = ""

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    unitStep.tag(1)
                    exerciseSetupStep.tag(2)
                    configStep.tag(3)
                    readyStep.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(i == step ? theme.accentColor : theme.textSecondary.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Steps

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 80))
                .foregroundStyle(theme.accentColor)

            Text("How to Become\na Bear")
                .font(.system(size: 34, weight: .bold))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("DeLorme Hypertrophy Program")
                .font(.title3)
                .foregroundStyle(theme.textSecondary)

            Spacer()

            nextButton(label: "Get Started")
        }
        .padding()
    }

    private var unitStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Weight Unit")
                .font(.title.bold())

            Picker("Unit", selection: $unit) {
                Text("kg").tag(WeightUnit.kg)
                Text("lbs").tag(WeightUnit.lbs)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 200)

            Spacer()

            nextButton(label: "Next")
        }
        .padding()
    }

    private var exerciseSetupStep: some View {
        VStack(spacing: 20) {
            Text("Your Starting Weights")
                .font(.title.bold())
                .padding(.top, 40)

            Text("Enter the most weight you can lift for 10 reps with good form (your 10RM).")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                exerciseInput(
                    name: "Push-up Level",
                    icon: "figure.push.up"
                ) {
                    Picker("Level", selection: $pushUpLevel) {
                        Text("Regular").tag(PushUpVariant.regular)
                        Text("Archer").tag(PushUpVariant.archer)
                        Text("One Arm").tag(PushUpVariant.oneArm)
                    }
                    .pickerStyle(.segmented)
                }

                exerciseInput(
                    name: "1-Arm Pulldown",
                    icon: "figure.rowing"
                ) {
                    HStack {
                        TextField("10RM", value: $pulldownRM, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        Text(unit.symbol)
                            .foregroundStyle(theme.textSecondary)
                    }
                }

                exerciseInput(
                    name: "Zercher Squat",
                    icon: "figure.squat"
                ) {
                    HStack {
                        TextField("10RM", value: $zercherRM, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        Text(unit.symbol)
                            .foregroundStyle(theme.textSecondary)
                    }
                }
            }
            .padding()

            Spacer()

            nextButton(label: "Next")
        }
        .padding()
    }

    private var configStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Program Setup")
                .font(.title.bold())

            Toggle("Include 2-Week Intro Cycle", isOn: $includeIntro)
                .padding()
                .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))

            Text("The intro cycle helps you find your 10RM and get comfortable with the exercises.")
                .font(.caption)
                .foregroundStyle(theme.textSecondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Bodyweight (optional)")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                HStack {
                    TextField("e.g. 68", text: $bodyweight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Text(unit.symbol)
                        .foregroundStyle(theme.textSecondary)
                }
            }
            .padding()
            .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))

            Spacer()

            nextButton(label: "Next")
        }
        .padding()
    }

    private var readyStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(theme.completedColor)

            Text("Ready to Train")
                .font(.title.bold())

            VStack(alignment: .leading, spacing: 8) {
                summaryRow("Push-up", pushUpLevel.rawValue)
                summaryRow("1-Arm Pulldown", "\(formatted(pulldownRM)) \(unit.symbol)")
                summaryRow("Zercher Squat", "\(formatted(zercherRM)) \(unit.symbol)")
                summaryRow("Intro Cycle", includeIntro ? "Included" : "Skipped")
                if let bw = Double(bodyweight) {
                    summaryRow("Bodyweight", "\(formatted(bw)) \(unit.symbol)")
                }
            }
            .padding()
            .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))

            Spacer()

            Button {
                createProgram()
                onComplete()
            } label: {
                Text("Start Program")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.accentColor)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding()
    }

    // MARK: - Helpers

    private func exerciseInput<Content: View>(
        name: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(name, systemImage: icon)
                .font(.headline)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(theme.textSecondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }

    private func nextButton(label: String) -> some View {
        Button {
            withAnimation { step += 1 }
        } label: {
            Text(label)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.accentColor)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.bottom, 40)
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }

    private func createProgram() {
        let program = Program(
            startDate: .now,
            introCycleEnabled: includeIntro
        )

        let exercises = [
            Exercise(name: "Push-up", type: .bodyweight, initial10RM: 0, weightIncrement: 0, unit: unit, sortOrder: 0),
            Exercise(name: "1-Arm Pulldown", type: .weighted, initial10RM: pulldownRM, weightIncrement: 2.5, unit: unit, sortOrder: 1),
            Exercise(name: "Zercher Squat", type: .weighted, initial10RM: zercherRM, weightIncrement: 5, unit: unit, sortOrder: 2)
        ]

        for exercise in exercises {
            exercise.program = program
            program.exercises.append(exercise)
        }

        modelContext.insert(program)

        if let bw = Double(bodyweight) {
            let entry = BodyweightEntry(weight: bw, unit: unit)
            modelContext.insert(entry)
        }

        try? modelContext.save()
    }
}
