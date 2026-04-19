import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @State private var step = 0
    @State private var unit: WeightUnit = .kg
    @State private var includeIntro = true
    @State private var selectedTemplate: ProgramTemplate = .classic
    @State private var exerciseWeights: [String: Double] = [:]
    @State private var pushUpStart: PushUpVariant = .regular
    @State private var syncHealth = false
    @State private var healthKitManager = HealthKitManager()

    let onComplete: () -> Void

    private let totalSteps = 5

    var body: some View {
        NavigationStack {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    programPickerStep.tag(1)
                    weightSetupStep.tag(2)
                    configStep.tag(3)
                    readyStep.tag(4)
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

            BarbellGlyph(color: theme.accentColor)
                .padding(.top, 24)
                .opacity(subtitleVisible ? 1 : 0)

            NavigationLink {
                HowItWorksView()
            } label: {
                Text("How it works →")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(theme.accentColor)
            }
            .padding(.top, 20)
            .opacity(linkVisible ? 1 : 0)

            Spacer()
            Spacer()

            ctaButton("Get Started") {
                withAnimation { step = 1 }
            }
        }
        .padding(.horizontal, 28)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) { titleVisible = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.35)) { subtitleVisible = true }
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) { linkVisible = true }
        }
    }

    // MARK: - Program Picker

    private var programPickerStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 60)

            Text("Choose Your\nProgram")
                .font(.system(size: 28, weight: .bold))

            Text("Same method, different exercises.")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .padding(.top, 8)
                .padding(.bottom, 32)

            VStack(spacing: 12) {
                ForEach(ProgramTemplate.all) { template in
                    let isSelected = selectedTemplate.id == template.id

                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedTemplate = template
                            initWeights()
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(template.name)
                                    .font(.headline)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(theme.accentColor)
                                }
                            }

                            Text(template.subtitle)
                                .font(.caption)
                                .foregroundStyle(theme.textSecondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(theme.cardColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(isSelected ? theme.accentColor.opacity(0.5) : .clear, lineWidth: 1.5)
                                )
                        )
                    }
                    .foregroundStyle(.white)
                }
            }

            Spacer()

            ctaButton("Continue") {
                initWeights()
                withAnimation { step = 2 }
            }
        }
        .padding(.horizontal, 28)
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
                .onChange(of: unit) { initWeights() }
            }

            Text("A conservative estimate of the most\nyou can lift for 10 reps with good form.")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .lineSpacing(4)
                .padding(.top, 8)
                .padding(.bottom, 32)

            VStack(spacing: 16) {
                ForEach(selectedTemplate.exercises, id: \.name) { exercise in
                    if exercise.type == .weighted {
                        weightCard(exercise: exercise)
                    } else {
                        bodyweightCard(exercise: exercise)
                    }
                }
            }

            Spacer()

            ctaButton("Continue") {
                withAnimation { step = 3 }
            }
        }
        .padding(.horizontal, 28)
    }

    private func weightCard(exercise: ProgramTemplate.TemplateExercise) -> some View {
        let increment = unit == .kg ? exercise.increment : exercise.incrementLbs
        let weight = Binding(
            get: { exerciseWeights[exercise.name] ?? (unit == .kg ? exercise.defaultRM : exercise.defaultRMLbs) },
            set: { exerciseWeights[exercise.name] = $0 }
        )

        return VStack(spacing: 12) {
            HStack {
                Image(systemName: exercise.icon)
                    .font(.title3)
                    .foregroundStyle(theme.accentColor)
                Text(exercise.name)
                    .font(.headline)
                Spacer()
                Text("+\(formatted(increment)) \(unit.symbol)")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            HStack(spacing: 16) {
                Button {
                    if weight.wrappedValue > increment { weight.wrappedValue -= increment }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(theme.textSecondary)
                }
                .buttonStyle(.borderless)

                Text(formatted(weight.wrappedValue))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .frame(minWidth: 60)

                Button {
                    weight.wrappedValue += increment
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(theme.accentColor)
                }
                .buttonStyle(.borderless)

                Text(unit.symbol)
                    .font(.title3)
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(16)
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 16))
    }

    private func bodyweightCard(exercise: ProgramTemplate.TemplateExercise) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: exercise.icon)
                    .font(.title3)
                    .foregroundStyle(theme.accentColor)
                Text(exercise.name)
                    .font(.headline)
                Spacer()
            }

            Text("Starting level")
                .font(.caption)
                .foregroundStyle(theme.textSecondary)

            HStack(spacing: 6) {
                ForEach(PushUpVariant.allCases, id: \.self) { variant in
                    let isSelected = pushUpStart == variant
                    Button {
                        pushUpStart = variant
                    } label: {
                        Text(variant.rawValue)
                            .font(.caption2.weight(.medium))
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

            Text(PushUpVariant.progressionLabel(from: pushUpStart))
                .font(.caption)
                .foregroundStyle(theme.accentColor)
        }
        .padding(16)
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Config

    private var configStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 60)

            Text("Setup")
                .font(.system(size: 28, weight: .bold))

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
                withAnimation { step = 4 }
            }
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Ready

    private var readyStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 60)

            Text("Ready to Train")
                .font(.system(size: 28, weight: .bold))

            Text(selectedTemplate.name)
                .font(.subheadline)
                .foregroundStyle(theme.accentColor)
                .padding(.top, 4)
                .padding(.bottom, 24)

            VStack(spacing: 1) {
                ForEach(selectedTemplate.exercises, id: \.name) { exercise in
                    HStack {
                        Text(exercise.name)
                            .foregroundStyle(theme.textSecondary)
                        Spacer()
                        if exercise.type == .weighted {
                            let w = exerciseWeights[exercise.name] ?? (unit == .kg ? exercise.defaultRM : exercise.defaultRMLbs)
                            Text("\(formatted(w)) \(unit.symbol)")
                                .fontWeight(.semibold)
                        } else {
                            Text("Bodyweight")
                                .fontWeight(.semibold)
                                .foregroundStyle(theme.accentColor)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(theme.cardColor)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 8) {
                scheduleRow("Mon", "Heavy — max series", selectedTemplate.exercises.count == 2 ? "50% → 75% → 100%" : "50/75/100%")
                scheduleRow("Wed", "Light", "50% only")
                scheduleRow("Fri", "Medium", "50% → 75%")
            }
            .padding(16)
            .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 14))
            .padding(.top, 12)

            Spacer()

            ctaButton("Start Program") {
                createProgram()
                onComplete()
            }
        }
        .padding(.horizontal, 28)
    }

    private func scheduleRow(_ day: String, _ type: String, _ detail: String) -> some View {
        HStack {
            Text(day)
                .font(.caption.bold())
                .frame(width: 32, alignment: .leading)
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

    private func initWeights() {
        for exercise in selectedTemplate.exercises where exercise.type == .weighted {
            if exerciseWeights[exercise.name] == nil {
                exerciseWeights[exercise.name] = unit == .kg ? exercise.defaultRM : exercise.defaultRMLbs
            }
        }
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

        for (index, templateEx) in selectedTemplate.exercises.enumerated() {
            let increment = unit == .kg ? templateEx.increment : templateEx.incrementLbs
            let rm = exerciseWeights[templateEx.name] ?? (unit == .kg ? templateEx.defaultRM : templateEx.defaultRMLbs)

            let exercise = Exercise(
                name: templateEx.name,
                type: templateEx.type,
                initial10RM: rm,
                weightIncrement: increment,
                unit: unit,
                sortOrder: index,
                pushUpStart: templateEx.type == .bodyweight ? pushUpStart : .regular
            )
            exercise.program = program
            program.exercises.append(exercise)
        }

        modelContext.insert(program)
        try? modelContext.save()
    }
}
