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
    @State private var syncHealth = false
    @State private var healthKitManager = HealthKitManager()

    let onComplete: () -> Void

    private let totalSteps = 4

    var body: some View {
        NavigationStack {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    weightSetupStep.tag(1)
                    configStep.tag(2)
                    readyStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                dots
                    .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
        } // NavigationStack
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

    @State private var titleVisible = false
    @State private var subtitleVisible = false
    @State private var linkVisible = false

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            // Barbell glyph
            BarbellGlyph(color: theme.accentColor)
                .padding(.bottom, 24)
                .opacity(titleVisible ? 1 : 0)

            Text("Stronq")
                .font(.system(size: 56, weight: .heavy))
                .opacity(titleVisible ? 1 : 0)
                .offset(y: titleVisible ? 0 : 12)

            Text("Two exercises.\nSix weeks.\nSeriously strong.")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(theme.textSecondary)
                .lineSpacing(6)
                .padding(.top, 16)
                .opacity(subtitleVisible ? 1 : 0)
                .offset(y: subtitleVisible ? 0 : 8)

            NavigationLink {
                HowItWorksView()
            } label: {
                Text("How it works →")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(theme.accentColor)
            }
            .padding(.top, 24)
            .opacity(linkVisible ? 1 : 0)

            Spacer()
            Spacer()

            ctaButton("Get Started") {
                withAnimation { step = 1 }
            }
        }
        .padding(.horizontal, 28)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                titleVisible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
                subtitleVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
                linkVisible = true
            }
        }
    }

    // MARK: - Weight Setup

    private var weightSetupStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 60)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Your 10RM")
                    .font(.system(size: 28, weight: .bold))

                Picker("Unit", selection: $unit) {
                    Text("kg").tag(WeightUnit.kg)
                    Text("lbs").tag(WeightUnit.lbs)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 120)
                .onChange(of: unit) {
                    if unit == .lbs {
                        benchRM = 135
                        deadliftRM = 175
                    } else {
                        benchRM = 60
                        deadliftRM = 80
                    }
                }
            }

            Text("A conservative estimate of the most\nyou can lift for 10 reps with good form.")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .lineSpacing(4)
                .padding(.top, 8)
                .padding(.bottom, 32)

            VStack(spacing: 16) {
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

            Spacer()

            ctaButton("Continue") {
                withAnimation { step = 2 }
            }
        }
        .padding(.horizontal, 28)
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
        VStack(alignment: .leading, spacing: 0) {
            Text("Setup")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 32)

            Text("A few options before you start.")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .padding(.top, 8)

            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Include 2-Week Intro Cycle", isOn: $includeIntro)
                        .tint(theme.accentColor)
                        .padding(16)
                        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 14))

                    Text("Builds up tonnage gradually before the\nfull Heavy-Light-Medium cycle.")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                        .padding(.leading, 4)
                }

                if healthKitManager.isAvailable {
                    Toggle(isOn: $syncHealth) {
                        Label("Sync with Apple Health", systemImage: "heart.fill")
                    }
                    .tint(theme.accentColor)
                    .padding(16)
                    .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 14))
                    .onChange(of: syncHealth) {
                        if syncHealth {
                            Task { await healthKitManager.requestAuthorization() }
                        }
                    }
                }
            }
            .padding(.top, 32)

            Spacer()

            ctaButton("Continue") {
                withAnimation { step = 3 }
            }
        }
        .padding(.horizontal, 28)
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
                scheduleRow("Mon", "Heavy — max series", "50% → 75% → 100%")
                scheduleRow("Wed", "Light", "50% only")
                scheduleRow("Fri", "Medium", "50% → 75%")
            }
            .padding()
            .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 14))

            Spacer()

            ctaButton("Start Program") {
                createProgram()
                onComplete()
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
