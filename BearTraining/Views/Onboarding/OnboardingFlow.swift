import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @State private var step = 0
    @State private var unit: WeightUnit = .kg
    @State private var includeIntro = true
    @State private var selectedExercises: Set<String> = []
    @State private var exerciseWeights: [String: Double] = [:]
    @State private var bodyweight: String = ""

    let onComplete: () -> Void

    private let totalSteps = 5

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

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
        case 1: exercisePickerStep
        case 2: weightEntryStep
        case 3: configStep
        case 4: readyStep
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

            Text("DeLorme Hypertrophy Program")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .tracking(1)
                .textCase(.uppercase)

            Spacer()
            Spacer()

            ctaButton("Get Started") {
                withAnimation { step = 1 }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Exercise Picker

    private var exercisePickerStep: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Choose Your Exercises")
                    .font(.title2.bold())
                Text("Pick 2 or 3 compound movements")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(ExerciseTemplate.ExerciseCategory.allCases, id: \.self) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.rawValue)
                                .font(.caption.bold())
                                .foregroundStyle(theme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)
                                .padding(.horizontal, 4)

                            let exercises = ExerciseTemplate.catalog.filter { $0.category == category }
                            ForEach(exercises) { template in
                                exerciseRow(template)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            ctaButton("Continue") {
                for id in selectedExercises {
                    if let template = ExerciseTemplate.catalog.first(where: { $0.id == id }),
                       template.type == .weighted {
                        exerciseWeights[id] = template.defaultIncrement * 10
                    }
                }
                withAnimation { step = 2 }
            }
            .disabled(selectedExercises.count < 2)
            .opacity(selectedExercises.count < 2 ? 0.5 : 1)
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
    }

    private func exerciseRow(_ template: ExerciseTemplate) -> some View {
        let isSelected = selectedExercises.contains(template.id)
        let atLimit = selectedExercises.count >= 3 && !isSelected

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if isSelected {
                    selectedExercises.remove(template.id)
                } else if !atLimit {
                    selectedExercises.insert(template.id)
                }
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: template.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? theme.accentColor : theme.textSecondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(template.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(isSelected ? .white : theme.textSecondary)
                    Text(template.type == .bodyweight ? "Bodyweight" : "Weighted")
                        .font(.caption2)
                        .foregroundStyle(theme.textSecondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? theme.accentColor : Color.white.opacity(0.15))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.accentColor.opacity(0.1) : theme.cardColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? theme.accentColor.opacity(0.4) : .clear, lineWidth: 1)
                    )
            )
        }
        .disabled(atLimit)
        .opacity(atLimit ? 0.4 : 1)
    }

    // MARK: - Weight Entry

    private var weightEntryStep: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Starting Weights")
                    .font(.title2.bold())
                Text("Enter your 10RM — the most you can\nlift for 10 reps with good form")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.bottom, 8)

            Picker("Unit", selection: $unit) {
                Text("kg").tag(WeightUnit.kg)
                Text("lbs").tag(WeightUnit.lbs)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 140)
            .padding(.bottom, 24)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(selectedTemplates) { template in
                        if template.type == .weighted {
                            weightInputCard(template)
                        } else {
                            bodyweightCard(template)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            ctaButton("Continue") {
                withAnimation { step = 3 }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
    }

    private func weightInputCard(_ template: ExerciseTemplate) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(template.name, systemImage: template.icon)
                .font(.headline)

            HStack(spacing: 16) {
                Text("10RM")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        let current = exerciseWeights[template.id] ?? 0
                        if current > 0 { exerciseWeights[template.id] = current - 2.5 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(theme.textSecondary)
                    }

                    Text(formatted(exerciseWeights[template.id] ?? 0))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .frame(minWidth: 60)

                    Button {
                        let current = exerciseWeights[template.id] ?? 0
                        exerciseWeights[template.id] = current + 2.5
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(theme.accentColor)
                    }
                }

                Text(unit.symbol)
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }

            HStack {
                Text("Weekly increment")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                Spacer()
                Text("+\(formatted(template.defaultIncrement)) \(unit.symbol)")
                    .font(.caption.bold())
                    .foregroundStyle(theme.accentColor)
            }
        }
        .padding(16)
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 14))
    }

    private func bodyweightCard(_ template: ExerciseTemplate) -> some View {
        HStack(spacing: 14) {
            Image(systemName: template.icon)
                .font(.title3)
                .foregroundStyle(theme.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.headline)
                Text("Bodyweight — progression through variants")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(theme.completedColor)
        }
        .padding(16)
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Config

    private var configStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Program Setup")
                .font(.title2.bold())

            VStack(spacing: 12) {
                Toggle("Include 2-Week Intro Cycle", isOn: $includeIntro)
                    .tint(theme.accentColor)
                    .padding(16)
                    .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 14))

                Text("The intro helps you dial in your 10RM and learn the movement patterns.")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                    .padding(.horizontal, 4)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("BODYWEIGHT")
                    .font(.caption.bold())
                    .foregroundStyle(theme.textSecondary)
                    .tracking(1)
                HStack(spacing: 12) {
                    TextField("e.g. 68", text: $bodyweight)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .frame(width: 80)
                    Text(unit.symbol)
                        .foregroundStyle(theme.textSecondary)
                    Spacer()
                    Text("optional")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                .padding(16)
                .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 14))
            }

            Spacer()

            ctaButton("Continue") {
                withAnimation { step = 4 }
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
                ForEach(Array(selectedTemplates.enumerated()), id: \.element.id) { index, template in
                    HStack {
                        Text(template.name)
                            .foregroundStyle(theme.textSecondary)
                        Spacer()
                        if template.type == .weighted {
                            Text("\(formatted(exerciseWeights[template.id] ?? 0)) \(unit.symbol)")
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

                    if index < selectedTemplates.count - 1 {
                        Divider().overlay(theme.backgroundColor)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))

            HStack {
                Label(
                    includeIntro ? "Intro + 6 weeks" : "6 weeks",
                    systemImage: "calendar"
                )
                Spacer()
                if let bw = Double(bodyweight) {
                    Label("\(formatted(bw)) \(unit.symbol)", systemImage: "scalemass")
                }
            }
            .font(.subheadline)
            .foregroundStyle(theme.textSecondary)
            .padding(.horizontal, 4)

            Spacer()

            ctaButton("Start Program") {
                createProgram()
                onComplete()
            }
        }
        .padding(.horizontal, 24)
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

    private var selectedTemplates: [ExerciseTemplate] {
        ExerciseTemplate.catalog.filter { selectedExercises.contains($0.id) }
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

        for (index, template) in selectedTemplates.enumerated() {
            let exercise = Exercise(
                name: template.name,
                type: template.type,
                initial10RM: exerciseWeights[template.id] ?? 0,
                weightIncrement: template.defaultIncrement,
                unit: unit,
                sortOrder: index
            )
            exercise.program = program
            program.exercises.append(exercise)
        }

        modelContext.insert(program)

        if let bw = Double(bodyweight) {
            modelContext.insert(BodyweightEntry(weight: bw, unit: unit))
        }

        try? modelContext.save()
    }
}
