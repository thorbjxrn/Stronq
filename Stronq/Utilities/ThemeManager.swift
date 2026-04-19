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
        case .crimson: "Crimson"
        case .midnight: "Midnight"
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
        case .chalk: Color(red: 0.40, green: 0.40, blue: 0.42)
        case .crimson: Color(red: 0.85, green: 0.20, blue: 0.22)
        case .midnight: Color(red: 0.35, green: 0.50, blue: 0.95)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .bear: Color(red: 0.08, green: 0.08, blue: 0.10)
        case .chalk: Color(.systemBackground)
        case .crimson: Color(red: 0.09, green: 0.06, blue: 0.06)
        case .midnight: Color(red: 0.05, green: 0.05, blue: 0.10)
        }
    }

    var cardColor: Color {
        switch self {
        case .bear: Color(red: 0.14, green: 0.14, blue: 0.16)
        case .chalk: Color(.secondarySystemBackground)
        case .crimson: Color(red: 0.16, green: 0.10, blue: 0.10)
        case .midnight: Color(red: 0.10, green: 0.10, blue: 0.18)
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
        case .chalk: Color(red: 0.25, green: 0.70, blue: 0.35)
        case .crimson: Color(red: 0.90, green: 0.45, blue: 0.30)
        case .midnight: Color(red: 0.30, green: 0.80, blue: 0.70)
        }
    }

    var themePreviewColor: Color {
        switch self {
        case .bear: Color(red: 0.96, green: 0.65, blue: 0.14)
        case .chalk: Color(red: 0.85, green: 0.85, blue: 0.85)
        case .crimson: Color(red: 0.85, green: 0.20, blue: 0.22)
        case .midnight: Color(red: 0.35, green: 0.50, blue: 0.95)
        }
    }
}
