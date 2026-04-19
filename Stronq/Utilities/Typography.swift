import SwiftUI

// MARK: - Typography System
//
// Stronq type system. SF Pro only. Four hierarchy levels plus two
// specialist styles (.rounded for weight numbers, .monospaced for timers).
//
// Hierarchy (top to bottom):
//   hero       56pt heavy     App title, celebration headlines
//   title      28pt bold      Section titles, screen headers
//   heading    17pt semibold  Card titles, exercise names, CTA buttons
//   body       15pt regular   Descriptions, secondary buttons, day labels
//   caption    13pt regular   Helper text, metadata
//   small      11pt medium    Pills, chips, badges, footnotes
//
// Specialist:
//   weightLarge      40pt bold rounded    Stepper weight numbers (onboarding, settings)
//   weightStandard   17pt semibold rounded Weight numbers in workout cards
//   timer            22pt bold monospaced  Countdown / elapsed time

enum Typo {

    // MARK: - Hero

    /// 56pt heavy. App title on welcome screen, "Well done" celebration.
    static var hero: Font {
        .system(size: 56, weight: .heavy)
    }

    // MARK: - Title

    /// 28pt bold. Section titles: "Your 10RM", "Setup", "Ready to Train".
    static var title: Font {
        .system(size: 28, weight: .bold)
    }

    // MARK: - Heading

    /// 17pt (headline) semibold. Exercise names, card titles, CTA button labels.
    static var heading: Font {
        .system(.headline)
    }

    // MARK: - Body

    /// 15pt (subheadline) regular. Day type labels, descriptions, secondary buttons.
    static var body: Font {
        .subheadline
    }

    /// 15pt (subheadline) semibold. Emphasized body: intensity labels, series labels.
    static var bodyEmphasis: Font {
        .subheadline.weight(.semibold)
    }

    // MARK: - Caption

    /// 13pt (caption) regular. Helper text, metadata, rep counts.
    static var caption: Font {
        .caption
    }

    /// 13pt (caption) bold. Emphasized captions: section headers in lists.
    static var captionEmphasis: Font {
        .caption.bold()
    }

    // MARK: - Small

    /// 11pt (caption2) medium. Pill labels, chip labels, badges, footnotes.
    static var small: Font {
        .caption2.weight(.medium)
    }

    // MARK: - Weight Numbers (Rounded)

    /// 40pt bold rounded. Large weight display in steppers (onboarding, settings).
    static var weightLarge: Font {
        .system(size: 40, weight: .bold, design: .rounded)
    }

    /// 17pt (body) semibold rounded. Weight numbers inside workout cards.
    static var weightStandard: Font {
        .system(.body, design: .rounded, weight: .semibold)
    }

    // MARK: - Timer (Monospaced)

    /// 22pt bold monospaced. Active countdown or elapsed timer display.
    static var timer: Font {
        .system(.title2, design: .monospaced, weight: .bold)
    }

    /// 15pt (subheadline) regular monospaced. Inline timer reference, smaller contexts.
    static var timerCompact: Font {
        .system(.subheadline, design: .monospaced)
    }

    // MARK: - Stepper Controls

    /// 32pt regular. Plus/minus buttons flanking weight steppers.
    static var stepperButton: Font {
        .system(size: 32)
    }

    // MARK: - Stat Bubble

    /// 20pt (title3) bold rounded. Stat values on completion screen.
    static var statValue: Font {
        .system(.title3, design: .rounded, weight: .bold)
    }

    /// 11pt (caption2) regular. Stat labels below values ("Time", "Series", "Volume").
    static var statLabel: Font {
        .caption2
    }

    // MARK: - Tab Label

    /// 12pt medium. Tab labels in segmented workout view.
    static var tabLabel: Font {
        .system(size: 12, weight: .medium)
    }
}
