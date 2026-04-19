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
}

enum AppTheme: String, CaseIterable {
    case bear
    case iron
    case forest
    case arctic

    var displayName: String {
        switch self {
        case .bear: "Stronq (Default)"
        case .iron: "Iron"
        case .forest: "Forest"
        case .arctic: "Arctic"
        }
    }

    var isPremium: Bool {
        self != .bear
    }

    var accentColor: Color {
        switch self {
        case .bear: Color(red: 0.96, green: 0.65, blue: 0.14)    // #F5A623 amber/gold
        case .iron: Color(red: 0.75, green: 0.75, blue: 0.78)    // steel
        case .forest: Color(red: 0.35, green: 0.71, blue: 0.45)  // forest green
        case .arctic: Color(red: 0.45, green: 0.75, blue: 0.95)  // ice blue
        }
    }

    var backgroundColor: Color {
        switch self {
        case .bear: Color(red: 0.08, green: 0.08, blue: 0.10)
        case .iron: Color(red: 0.07, green: 0.07, blue: 0.09)
        case .forest: Color(red: 0.06, green: 0.10, blue: 0.08)
        case .arctic: Color(red: 0.06, green: 0.08, blue: 0.12)
        }
    }

    var cardColor: Color {
        switch self {
        case .bear: Color(red: 0.14, green: 0.14, blue: 0.16)
        case .iron: Color(red: 0.13, green: 0.13, blue: 0.15)
        case .forest: Color(red: 0.10, green: 0.15, blue: 0.12)
        case .arctic: Color(red: 0.10, green: 0.13, blue: 0.18)
        }
    }

    var textPrimary: Color { .white }
    var textSecondary: Color { Color(white: 0.6) }

    var completedColor: Color {
        switch self {
        case .bear: Color(red: 0.30, green: 0.78, blue: 0.40)
        case .iron: Color(red: 0.40, green: 0.80, blue: 0.45)
        case .forest: Color(red: 0.35, green: 0.85, blue: 0.50)
        case .arctic: Color(red: 0.35, green: 0.80, blue: 0.90)
        }
    }
}
