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
        case .champagne: "Champagne"
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
        case .chalk, .cryo, .infrared, .champagne: nil
        default: .dark
        }
    }

    var isDynamic: Bool {
        preferredColorScheme == nil
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
        // Deep crimson-burgundy — intense but not destructive
        case .testo: Color(red: 0.75, green: 0.18, blue: 0.18)
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
        case .champagne: Color(.systemBackground)
        case .chalk: Color(.systemBackground)
        // Pitch black
        case .testo: Color(red: 0.03, green: 0.02, blue: 0.02)
        case .tactical: Color(red: 0.03, green: 0.05, blue: 0.03)
        case .infrared: Color(.systemBackground)
        case .cryo: Color(.systemBackground)
        }
    }

    var cardColor: Color {
        switch self {
        case .stronq: Color(red: 0.10, green: 0.09, blue: 0.08)
        case .amber: Color(red: 0.14, green: 0.14, blue: 0.16)
        case .champagne: Color(.secondarySystemBackground)
        case .chalk: Color(.secondarySystemBackground)
        // Dark blood-tinged charcoal
        case .testo: Color(red: 0.10, green: 0.05, blue: 0.05)
        case .tactical: Color(red: 0.06, green: 0.10, blue: 0.07)
        case .infrared: Color(.secondarySystemBackground)
        case .cryo: Color(.secondarySystemBackground)
        }
    }

    var textPrimary: Color {
        switch self {
        case .chalk, .champagne, .infrared, .cryo: Color(.label)
        case .stronq: Color(red: 0.90, green: 0.88, blue: 0.84)
        // Bone white
        case .testo: Color(red: 0.95, green: 0.93, blue: 0.90)
        case .tactical: Color(red: 0.80, green: 0.92, blue: 0.82)
        default: .white
        }
    }

    var textSecondary: Color {
        switch self {
        case .chalk, .champagne, .infrared, .cryo: Color(.secondaryLabel)
        case .stronq: Color(red: 0.50, green: 0.47, blue: 0.42)
        case .testo: Color(red: 0.55, green: 0.35, blue: 0.32)
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
        // Sickly green-yellow — veins popping
        case .testo: Color(red: 0.70, green: 0.85, blue: 0.15)
        case .tactical: Color(red: 0.15, green: 0.85, blue: 0.40)
        case .infrared: Color(red: 0.95, green: 0.55, blue: 0.40)
        case .cryo: Color(red: 0.25, green: 0.85, blue: 0.60)
        }
    }

    var themePreviewColor: Color { accentColor }
}
