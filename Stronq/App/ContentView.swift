import SwiftUI

struct ContentView: View {
    @Environment(ThemeManager.self) private var theme

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "figure.strengthtraining.traditional")
                }

            ProgramOverviewView()
                .tabItem {
                    Label("Program", systemImage: "calendar")
                }

            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(theme.accentColor)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environment(ThemeManager())
}
