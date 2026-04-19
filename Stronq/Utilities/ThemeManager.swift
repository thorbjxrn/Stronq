import SwiftUI

@Observable
final class ThemeManager {
    var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.stronq.rawValue
        self.currentTheme = AppTheme(rawValue: saved) ?? .stronq
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
    case stronq
    case amber
    case champagne
    case chalk
    case testo
    case tactical
    case infrared
    case cryo

    var displayName: String {
        switch self {
        case .stronq: "Stronq (Default)"
        case .amber: "Amber"
        case .champagne: "Copper"
        case .chalk: "Chalk"
        case .testo: "Testo"
        case .tactical: "Tactical"
        case .infrared: "Infrared"
        case .cryo: "Cryo"
        }
    }

    var isPremium: Bool {
        self != .stronq
    }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .stronq, .chalk, .cryo, .infrared: nil
        default: .dark
        }
    }

    var isDynamic: Bool {
        preferredColorScheme == nil
    }

    var accentColor: Color {
        switch self {
        // Champagne pink-gold — the clean one
        case .stronq: Color(red: 0.85, green: 0.75, blue: 0.55)
        case .amber: Color(red: 0.96, green: 0.65, blue: 0.14)
        // Copper-brown — dark only
        case .champagne: Color(red: 0.82, green: 0.60, blue: 0.36)
        case .chalk: Color(red: 0.45, green: 0.43, blue: 0.40)
        case .testo: Color(red: 0.75, green: 0.18, blue: 0.18)
        case .tactical: Color(red: 0.10, green: 0.78, blue: 0.35)
        case .infrared: Color(red: 0.92, green: 0.28, blue: 0.50)
        case .cryo: Color(red: 0.20, green: 0.82, blue: 0.88)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .stronq: Color(.systemBackground)
        case .amber: Color(red: 0.08, green: 0.08, blue: 0.10)
        case .champagne: Color(red: 0.05, green: 0.04, blue: 0.04)
        case .chalk: Color(.systemBackground)
        case .testo: Color(red: 0.03, green: 0.02, blue: 0.02)
        case .tactical: Color(red: 0.03, green: 0.05, blue: 0.03)
        case .infrared: Color(.systemBackground)
        case .cryo: Color(.systemBackground)
        }
    }

    var cardColor: Color {
        switch self {
        case .stronq: Color(.secondarySystemBackground)
        case .amber: Color(red: 0.14, green: 0.14, blue: 0.16)
        case .champagne: Color(red: 0.13, green: 0.11, blue: 0.10)
        case .chalk: Color(.secondarySystemBackground)
        case .testo: Color(red: 0.10, green: 0.05, blue: 0.05)
        case .tactical: Color(red: 0.06, green: 0.10, blue: 0.07)
        case .infrared: Color(.secondarySystemBackground)
        case .cryo: Color(.secondarySystemBackground)
        }
    }

    var textPrimary: Color {
        switch self {
        case .stronq, .chalk, .infrared, .cryo: Color(.label)
        case .champagne: Color(red: 0.94, green: 0.93, blue: 0.91)
        case .testo: Color(red: 0.95, green: 0.93, blue: 0.90)
        case .tactical: Color(red: 0.80, green: 0.92, blue: 0.82)
        default: .white
        }
    }

    var textSecondary: Color {
        switch self {
        case .stronq, .chalk, .infrared, .cryo: Color(.secondaryLabel)
        case .champagne: Color(red: 0.58, green: 0.54, blue: 0.50)
        case .testo: Color(red: 0.55, green: 0.35, blue: 0.32)
        case .tactical: Color(red: 0.35, green: 0.50, blue: 0.38)
        default: Color(white: 0.6)
        }
    }

    var completedColor: Color {
        switch self {
        case .stronq: Color(red: 0.30, green: 0.78, blue: 0.40)
        case .amber: Color(red: 0.30, green: 0.78, blue: 0.40)
        case .champagne: Color(red: 0.85, green: 0.72, blue: 0.30)
        case .chalk: Color(red: 0.30, green: 0.68, blue: 0.38)
        case .testo: Color(red: 0.70, green: 0.85, blue: 0.15)
        case .tactical: Color(red: 0.15, green: 0.85, blue: 0.40)
        case .infrared: Color(red: 0.95, green: 0.55, blue: 0.40)
        case .cryo: Color(red: 0.25, green: 0.85, blue: 0.60)
        }
    }

    var themePreviewColor: Color { accentColor }
}
