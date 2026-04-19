import SwiftUI

@Observable
final class ThemeManager {
    var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.bear.rawValue
        self.currentTheme = AppTheme(rawValue: saved) ?? .bear
    }

    var accentColor: Color { currentTheme.accentColor }
    var backgroundColor: Color { currentTheme.backgroundColor }
    var cardColor: Color { currentTheme.cardColor }
    var textPrimary: Color { currentTheme.textPrimary }
    var textSecondary: Color { currentTheme.textSecondary }
    var completedColor: Color { currentTheme.completedColor }
    var isPremiumTheme: Bool { currentTheme.isPremium }
    var preferredColorScheme: ColorScheme? { currentTheme.preferredColorScheme }
}

enum AppTheme: String, CaseIterable {
    case bear
    case chalk
    case crimson
    case midnight
    case obsidian
    case tactical

    var displayName: String {
        switch self {
        case .bear: "Stronq (Default)"
        case .chalk: "Chalk"
        case .crimson: "Infrared"
        case .midnight: "Cryo"
        case .obsidian: "Obsidian"
        case .tactical: "Tactical"
        }
    }

    var isPremium: Bool {
        self != .bear
    }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .chalk: nil
        default: .dark
        }
    }

    var accentColor: Color {
        switch self {
        case .bear: Color(red: 0.96, green: 0.65, blue: 0.14)
        case .chalk: Color(red: 0.88, green: 0.86, blue: 0.82)
        case .crimson: Color(red: 0.92, green: 0.28, blue: 0.50)
        case .midnight: Color(red: 0.20, green: 0.82, blue: 0.88)
        // Muted bronze — dark, heavy, masculine
        case .obsidian: Color(red: 0.72, green: 0.58, blue: 0.42)
        // OD green — military olive drab
        case .tactical: Color(red: 0.55, green: 0.62, blue: 0.38)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .bear: Color(red: 0.08, green: 0.08, blue: 0.10)
        case .chalk: Color(.systemBackground)
        case .crimson: Color(red: 0.08, green: 0.05, blue: 0.06)
        case .midnight: Color(red: 0.04, green: 0.05, blue: 0.09)
        // Pure black — heavy, no-nonsense
        case .obsidian: Color(red: 0.04, green: 0.04, blue: 0.04)
        // Dark olive-black
        case .tactical: Color(red: 0.06, green: 0.07, blue: 0.05)
        }
    }

    var cardColor: Color {
        switch self {
        case .bear: Color(red: 0.14, green: 0.14, blue: 0.16)
        case .chalk: Color(.secondarySystemBackground)
        case .crimson: Color(red: 0.14, green: 0.09, blue: 0.11)
        case .midnight: Color(red: 0.08, green: 0.09, blue: 0.16)
        // Dark charcoal with warm undertone
        case .obsidian: Color(red: 0.10, green: 0.09, blue: 0.08)
        // Dark khaki-green
        case .tactical: Color(red: 0.11, green: 0.12, blue: 0.09)
        }
    }

    var textPrimary: Color {
        switch self {
        case .chalk: Color(.label)
        // Slightly warm white for obsidian
        case .obsidian: Color(red: 0.90, green: 0.88, blue: 0.84)
        // Sand/tan text for tactical
        case .tactical: Color(red: 0.85, green: 0.82, blue: 0.72)
        default: .white
        }
    }

    var textSecondary: Color {
        switch self {
        case .chalk: Color(.secondaryLabel)
        case .obsidian: Color(red: 0.50, green: 0.47, blue: 0.42)
        case .tactical: Color(red: 0.50, green: 0.52, blue: 0.42)
        default: Color(white: 0.6)
        }
    }

    var completedColor: Color {
        switch self {
        case .bear: Color(red: 0.30, green: 0.78, blue: 0.40)
        case .chalk: Color(red: 0.30, green: 0.68, blue: 0.38)
        case .crimson: Color(red: 0.95, green: 0.55, blue: 0.40)
        case .midnight: Color(red: 0.25, green: 0.85, blue: 0.60)
        // Dull gold — understated success
        case .obsidian: Color(red: 0.75, green: 0.65, blue: 0.35)
        // Olive green — mission complete
        case .tactical: Color(red: 0.45, green: 0.65, blue: 0.30)
        }
    }

    var themePreviewColor: Color {
        switch self {
        case .bear: Color(red: 0.96, green: 0.65, blue: 0.14)
        case .chalk: Color(red: 0.88, green: 0.86, blue: 0.82)
        case .crimson: Color(red: 0.92, green: 0.28, blue: 0.50)
        case .midnight: Color(red: 0.20, green: 0.82, blue: 0.88)
        case .obsidian: Color(red: 0.72, green: 0.58, blue: 0.42)
        case .tactical: Color(red: 0.55, green: 0.62, blue: 0.38)
        }
    }
}
