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

    var displayName: String {
        switch self {
        case .bear: "Stronq (Default)"
        case .chalk: "Chalk"
        case .crimson: "Infrared"
        case .midnight: "Cryo"
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
        // Warm off-white with slight cream cast — actual gym chalk
        case .chalk: Color(red: 0.88, green: 0.86, blue: 0.82)
        // Deep magenta-rose — intense but not destructive
        case .crimson: Color(red: 0.92, green: 0.28, blue: 0.50)
        // Cyan-teal — cold, technical, high-contrast on dark
        case .midnight: Color(red: 0.20, green: 0.82, blue: 0.88)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .bear: Color(red: 0.08, green: 0.08, blue: 0.10)
        case .chalk: Color(.systemBackground)
        // Warm near-black with subtle rose undertone
        case .crimson: Color(red: 0.08, green: 0.05, blue: 0.06)
        // Deep navy-black — cold and inky
        case .midnight: Color(red: 0.04, green: 0.05, blue: 0.09)
        }
    }

    var cardColor: Color {
        switch self {
        case .bear: Color(red: 0.14, green: 0.14, blue: 0.16)
        case .chalk: Color(.secondarySystemBackground)
        // Lifted dark with matching rose warmth
        case .crimson: Color(red: 0.14, green: 0.09, blue: 0.11)
        // Slightly lifted navy
        case .midnight: Color(red: 0.08, green: 0.09, blue: 0.16)
        }
    }

    var textPrimary: Color {
        switch self {
        case .chalk: Color(.label)
        default: .white
        }
    }

    var textSecondary: Color {
        switch self {
        case .chalk: Color(.secondaryLabel)
        default: Color(white: 0.6)
        }
    }

    var completedColor: Color {
        switch self {
        case .bear: Color(red: 0.30, green: 0.78, blue: 0.40)
        // Muted sage green — works in both light and dark mode
        case .chalk: Color(red: 0.30, green: 0.68, blue: 0.38)
        // Warm coral-peach — complements magenta without clashing
        case .crimson: Color(red: 0.95, green: 0.55, blue: 0.40)
        // Bright mint — cool complement to cyan accent
        case .midnight: Color(red: 0.25, green: 0.85, blue: 0.60)
        }
    }

    var themePreviewColor: Color {
        switch self {
        case .bear: Color(red: 0.96, green: 0.65, blue: 0.14)
        case .chalk: Color(red: 0.88, green: 0.86, blue: 0.82)
        case .crimson: Color(red: 0.92, green: 0.28, blue: 0.50)
        case .midnight: Color(red: 0.20, green: 0.82, blue: 0.88)
        }
    }
}
