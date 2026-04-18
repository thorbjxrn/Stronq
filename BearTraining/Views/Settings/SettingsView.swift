import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @Environment(PurchaseManager.self) private var purchaseManager
    @Query private var programs: [Program]
    @Query(sort: \BodyweightEntry.date, order: .reverse) private var bodyweightEntries: [BodyweightEntry]
    @State private var showingPaywall = false
    @State private var newBodyweight: String = ""

    private var program: Program? { programs.first }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                List {
                    exercisesSection
                    programSection
                    bodyweightSection
                    appearanceSection
                    premiumSection
                    aboutSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Exercises

    private var exercisesSection: some View {
        Section("Exercises") {
            if let program {
                ForEach(program.exercises.sorted(by: { $0.sortOrder < $1.sortOrder })) { exercise in
                    NavigationLink {
                        ExerciseConfigView(exercise: exercise)
                    } label: {
                        HStack {
                            Text(exercise.name)
                            Spacer()
                            if exercise.type == .weighted {
                                Text("\(formatted(exercise.initial10RM)) \(exercise.unit.symbol)")
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Program

    private var programSection: some View {
        Section("Program") {
            if let program {
                Stepper("Set rest: \(program.restBetweenSets)s", value: Binding(
                    get: { program.restBetweenSets },
                    set: { program.restBetweenSets = $0 }
                ), in: 15...180, step: 15)

                Stepper("Series rest: \(program.restBetweenSeries)s", value: Binding(
                    get: { program.restBetweenSeries },
                    set: { program.restBetweenSeries = $0 }
                ), in: 60...600, step: 30)

                HStack {
                    Text("Unit")
                    Spacer()
                    Picker("", selection: Binding(
                        get: { program.exercises.first?.unit ?? .kg },
                        set: { unit in
                            program.exercises.forEach { $0.unit = unit }
                        }
                    )) {
                        Text("kg").tag(WeightUnit.kg)
                        Text("lbs").tag(WeightUnit.lbs)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
            }
        }
    }

    // MARK: - Bodyweight

    private var bodyweightSection: some View {
        Section("Bodyweight") {
            HStack {
                TextField("Add entry", text: $newBodyweight)
                    .keyboardType(.decimalPad)
                Button("Log") {
                    if let weight = Double(newBodyweight) {
                        let entry = BodyweightEntry(weight: weight, unit: program?.exercises.first?.unit ?? .kg)
                        modelContext.insert(entry)
                        newBodyweight = ""
                    }
                }
                .disabled(Double(newBodyweight) == nil)
            }

            if let latest = bodyweightEntries.first {
                HStack {
                    Text("Latest")
                    Spacer()
                    Text("\(formatted(latest.weight)) \(latest.unit.symbol)")
                        .foregroundStyle(theme.textSecondary)
                    Text(latest.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }
            }
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        Section("Appearance") {
            ForEach(AppTheme.allCases, id: \.self) { appTheme in
                Button {
                    if appTheme.isPremium && !purchaseManager.isPremium {
                        showingPaywall = true
                    } else {
                        theme.currentTheme = appTheme
                    }
                } label: {
                    HStack {
                        Circle()
                            .fill(appTheme.accentColor)
                            .frame(width: 24, height: 24)
                        Text(appTheme.displayName)
                        Spacer()
                        if appTheme.isPremium && !purchaseManager.isPremium {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(theme.textSecondary)
                        }
                        if theme.currentTheme == appTheme {
                            Image(systemName: "checkmark")
                                .foregroundStyle(theme.accentColor)
                        }
                    }
                }
                .foregroundStyle(theme.textPrimary)
            }
        }
    }

    // MARK: - Premium

    private var premiumSection: some View {
        Section("Premium") {
            if purchaseManager.isPremium {
                Label("Premium Active", systemImage: "crown.fill")
                    .foregroundStyle(theme.accentColor)
            } else {
                Button("Upgrade to Premium") {
                    showingPaywall = true
                }
                .foregroundStyle(theme.accentColor)
            }

            Button("Restore Purchases") {
                Task { await purchaseManager.restorePurchases() }
            }

            #if DEBUG
            Button("Toggle Premium (Debug)") {
                purchaseManager.debugTogglePremium()
            }
            #endif
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(theme.textSecondary)
            }

            #if DEBUG
            if let program {
                Section {
                    HStack {
                        Text("Current Week")
                        Spacer()
                        Text("\(program.currentWeek)")
                        Button("-") { if program.currentWeek > program.firstWeek { program.currentWeek -= 1 } }
                        Button("+") { if program.currentWeek < 7 { program.currentWeek += 1 } }
                    }

                    Button("Reset Program (delete all sessions)") {
                        for session in program.sessions {
                            modelContext.delete(session)
                        }
                        program.currentWeek = program.firstWeek
                        try? modelContext.save()
                    }
                    .foregroundStyle(.red)

                    Button("Reset Onboarding") {
                        for p in programs { modelContext.delete(p) }
                        try? modelContext.save()
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    }
                    .foregroundStyle(.red)
                } header: {
                    Text("Debug")
                }
            }
            #endif
        }
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}
