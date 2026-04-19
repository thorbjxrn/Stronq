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
    case bear
    case tactical
    case infrared
    case cryo

    var displayName: String {
        switch self {
        case .stronq: "Stronq (Default)"
        case .amber: "Amber"
        case .champagne: "Champagne"
        case .chalk: "Chalk"
        case .bear: "Bear"
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
        case .chalk: nil
        default: .dark
        }
    }

    var accentColor: Color {
        switch self {
        // Muted bronze on pure black — the original Coffee
        case .stronq: Color(red: 0.72, green: 0.58, blue: 0.42)
        // Classic saturated orange-amber
        case .amber: Color(red: 0.96, green: 0.65, blue: 0.14)
        // Desaturated pink-gold, brushed metal
        case .champagne: Color(red: 0.85, green: 0.75, blue: 0.55)
        // Warm off-white, system adaptive
        case .chalk: Color(red: 0.45, green: 0.43, blue: 0.40)
        // Burnt orange, honey and fur
        case .bear: Color(red: 0.82, green: 0.52, blue: 0.22)
        // Phosphor green, night vision
        case .tactical: Color(red: 0.10, green: 0.78, blue: 0.35)
        // Magenta-rose, hot
        case .infrared: Color(red: 0.92, green: 0.28, blue: 0.50)
        // Cyan-teal, cold
        case .cryo: Color(red: 0.20, green: 0.82, blue: 0.88)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .stronq: Color(red: 0.04, green: 0.04, blue: 0.04)
        case .amber: Color(red: 0.08, green: 0.08, blue: 0.10)
        case .champagne: Color(red: 0.07, green: 0.06, blue: 0.10)
        case .chalk: Color(.systemBackground)
        case .bear: Color(red: 0.08, green: 0.06, blue: 0.04)
        case .tactical: Color(red: 0.03, green: 0.05, blue: 0.03)
        case .infrared: Color(red: 0.08, green: 0.05, blue: 0.06)
        case .cryo: Color(red: 0.04, green: 0.05, blue: 0.09)
        }
    }

    var cardColor: Color {
        switch self {
        case .stronq: Color(red: 0.10, green: 0.09, blue: 0.08)
        case .amber: Color(red: 0.14, green: 0.14, blue: 0.16)
        case .champagne: Color(red: 0.12, green: 0.11, blue: 0.16)
        case .chalk: Color(.secondarySystemBackground)
        case .bear: Color(red: 0.14, green: 0.11, blue: 0.08)
        case .tactical: Color(red: 0.06, green: 0.10, blue: 0.07)
        case .infrared: Color(red: 0.14, green: 0.09, blue: 0.11)
        case .cryo: Color(red: 0.08, green: 0.09, blue: 0.16)
        }
    }

    var textPrimary: Color {
        switch self {
        case .chalk: Color(.label)
        case .stronq: Color(red: 0.90, green: 0.88, blue: 0.84)
        case .bear: Color(red: 0.95, green: 0.92, blue: 0.86)
        case .tactical: Color(red: 0.80, green: 0.92, blue: 0.82)
        default: .white
        }
    }

    var textSecondary: Color {
        switch self {
        case .chalk: Color(.secondaryLabel)
        case .stronq: Color(red: 0.50, green: 0.47, blue: 0.42)
        case .bear: Color(red: 0.58, green: 0.48, blue: 0.38)
        case .tactical: Color(red: 0.35, green: 0.50, blue: 0.38)
        default: Color(white: 0.6)
        }
    }

    var completedColor: Color {
        switch self {
        case .stronq: Color(red: 0.75, green: 0.65, blue: 0.35)
        case .amber: Color(red: 0.30, green: 0.78, blue: 0.40)
        case .champagne: Color(red: 0.30, green: 0.78, blue: 0.40)
        case .chalk: Color(red: 0.30, green: 0.68, blue: 0.38)
        case .bear: Color(red: 0.65, green: 0.78, blue: 0.32)
        case .tactical: Color(red: 0.15, green: 0.85, blue: 0.40)
        case .infrared: Color(red: 0.95, green: 0.55, blue: 0.40)
        case .cryo: Color(red: 0.25, green: 0.85, blue: 0.60)
        }
    }

    var themePreviewColor: Color { accentColor }
}
