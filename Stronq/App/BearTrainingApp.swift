import SwiftUI
import SwiftData
@preconcurrency import ActivityKit

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

        // Clean up any stale Live Activities from previous session
        Task {
            for activity in Activity<RestTimerAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
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
    @Environment(ThemeManager.self) private var theme
    @State private var showingLaunchBurst = false

    var body: some View {
        ZStack {
            if hasCompletedOnboarding && !programs.isEmpty {
                ContentView()
            } else {
                OnboardingFlow(onComplete: {
                    hasCompletedOnboarding = true
                    showingLaunchBurst = true
                })
            }

            if showingLaunchBurst {
                LaunchBurstView(theme: theme) {
                    showingLaunchBurst = false
                }
                .zIndex(100)
            }
        }
    }
}
