import SwiftUI
import SwiftData

@main
struct BearTrainingApp: App {
    @State private var purchaseManager = PurchaseManager()
    @State private var adManager: AdManager
    @State private var themeManager = ThemeManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Program.self,
            Exercise.self,
            WorkoutSession.self,
            CompletedSet.self,
            BodyweightEntry.self
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            let url = config.url
            try? FileManager.default.removeItem(at: url)
            do {
                modelContainer = try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("Failed to create ModelContainer after reset: \(error)")
            }
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        }

        let pm = PurchaseManager()
        _purchaseManager = State(initialValue: pm)
        _adManager = State(initialValue: AdManager(purchaseManager: pm))
    }

    var body: some Scene {
        WindowGroup {
            RootView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
        .modelContainer(modelContainer)
        .environment(purchaseManager)
        .environment(adManager)
        .environment(themeManager)
    }
}

struct RootView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Query private var programs: [Program]

    var body: some View {
        if hasCompletedOnboarding && !programs.isEmpty {
            ContentView()
        } else {
            OnboardingFlow(onComplete: {
                hasCompletedOnboarding = true
            })
        }
    }
}
