import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @State private var step = 0
    @State private var unit: WeightUnit = .kg
    @State private var includeIntro = true
    @State private var benchRM: Double = 60
    @State private var deadliftRM: Double = 80
    @State private var showingLaunch = false

    let onComplete: () -> Void

    private let totalSteps = 4

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            if showingLaunch {
                LaunchBurstView(theme: theme) {
                    onComplete()
                }
                .transition(.opacity)
                .zIndex(10)
            }

            VStack(spacing: 0) {
                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                dots
                    .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0: welcomeStep
        case 1: weightSetupStep
        case 2: configStep
        case 3: readyStep
        default: EmptyView()
        }
    }

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { i in
                Capsule()
                    .fill(i == step ? theme.accentColor : Color.white.opacity(0.2))
                    .frame(width: i == step ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: step)
            }
        }
    }

    // MARK: - Welcome

    private var welcomeStep: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(theme.accentColor)
                .padding(.bottom, 8)

            VStack(spacing: 12) {
                Text("How to Become")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text("a Bear")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.accentColor)
            }

            Text("DELORME HYPERTROPHY PROGRAM")
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
                .tracking(2)

            Spacer()
            Spacer()

            ctaButton("Get Started") {
                withAnimation { step = 1 }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Weight Setup

    private var weightSetupStep: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Your 10RM")
                    .font(.title2.bold())
                Text("A conservative estimate of the most you can\nlift for 10 reps with good form.")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)
            .padding(.bottom, 8)

            Picker("Unit", selection: $unit) {
                Text("kg").tag(WeightUnit.kg)
                Text("lbs").tag(WeightUnit.lbs)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 140)
            .padding(.bottom, 24)
            .onChange(of: unit) {
                if unit == .lbs {
                    benchRM = 135
                    deadliftRM = 175
                } else {
                    benchRM = 60
                    deadliftRM = 80
                }
            }

            Spacer()

            VStack(spacing: 24) {
                weightCard(
                    name: "Bench Press",
                    icon: "figure.strengthtraining.traditional",
                    weight: $benchRM,
                    increment: unit == .kg ? 2.5 : 5
                )

                weightCard(
                    name: "Deadlift",
                    icon: "figure.strengthtraining.functional",
                    weight: $deadliftRM,
                    increment: unit == .kg ? 5 : 10
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 4) {
                Text("Bench first, then deadlift — every session.")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                Text("No arms, no calves. Just these two.")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }
            .padding(.bottom, 8)

            ctaButton("Continue") {
                withAnimation { step = 2 }
            }
            .padding(.horizontal, 24)
        }
    }

    private func weightCard(
        name: String,
        icon: String,
        weight: Binding<Double>,
        increment: Double
    ) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(theme.accentColor)
                Text(name)
                    .font(.headline)
                Spacer()
                Text("+\(formatted(increment)) \(unit.symbol)/cycle")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            HStack(spacing: 16) {
                Button {
                    if weight.wrappedValue > 0 {
                        weight.wrappedValue -= increment
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(theme.textSecondary)
                }

                Text(formatted(weight.wrappedValue))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .frame(minWidth: 80)

                Button {
                    weight.wrappedValue += increment
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(theme.accentColor)
                }

                Text(unit.symbol)
                    .font(.title3)
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(20)
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Config

    private var configStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Program Setup")
                .font(.title2.bold())

            VStack(spacing: 16) {
                Toggle("Include 2-Week Intro Cycle", isOn: $includeIntro)
                    .tint(theme.accentColor)
                    .padding(16)
                    .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 14))

                Text("The intro builds up tonnage gradually before\nthe full Heavy-Light-Medium cycle begins.")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            ctaButton("Continue") {
                withAnimation { step = 3 }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Ready

    private var readyStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(theme.completedColor)

            Text("Ready to Train")
                .font(.title2.bold())

            VStack(spacing: 1) {
                summaryRow("Bench Press", "\(formatted(benchRM)) \(unit.symbol)")
                summaryRow("Deadlift", "\(formatted(deadliftRM)) \(unit.symbol)")
                summaryRow("Program", includeIntro ? "Intro + 6 weeks" : "6 weeks")
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 8) {
                scheduleRow("Monday", "Heavy — max series", "50% → 75% → 100%")
                scheduleRow("Wednesday", "Light", "50% only")
                scheduleRow("Friday", "Medium", "50% → 75%")
            }
            .padding()
            .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 14))

            Spacer()

            ctaButton("Start Program") {
                createProgram()
                withAnimation(.easeIn(duration: 0.3)) {
                    showingLaunch = true
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(theme.textSecondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(theme.cardColor)
    }

    private func scheduleRow(_ day: String, _ type: String, _ detail: String) -> some View {
        HStack {
            Text(day)
                .font(.caption.bold())
                .frame(width: 40, alignment: .leading)
            Text(type)
                .font(.caption)
            Spacer()
            Text(detail)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
        }
    }

    // MARK: - Components

    private func ctaButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(theme.accentColor, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.black)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }

    private func createProgram() {
        let benchIncrement: Double = unit == .kg ? 2.5 : 5
        let deadliftIncrement: Double = unit == .kg ? 5 : 10

        let program = Program(
            startDate: .now,
            introCycleEnabled: includeIntro
        )

        let bench = Exercise(
            name: "Bench Press",
            type: .weighted,
            initial10RM: benchRM,
            weightIncrement: benchIncrement,
            unit: unit,
            sortOrder: 0
        )
        let deadlift = Exercise(
            name: "Deadlift",
            type: .weighted,
            initial10RM: deadliftRM,
            weightIncrement: deadliftIncrement,
            unit: unit,
            sortOrder: 1
        )

        bench.program = program
        deadlift.program = program
        program.exercises.append(bench)
        program.exercises.append(deadlift)

        modelContext.insert(program)
        try? modelContext.save()
    }
}
