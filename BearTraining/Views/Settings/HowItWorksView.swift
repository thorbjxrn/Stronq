import SwiftUI

struct HowItWorksView: View {
    @Environment(ThemeManager.self) private var theme

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section(
                        "The Program",
                        icon: "figure.strengthtraining.traditional",
                        "A DeLorme-inspired hypertrophy cycle from Pavel Tsatsouline's Beyond Bodybuilding. Two exercises, three days a week, six weeks. Simple and brutally effective."
                    )

                    section(
                        "The Series",
                        icon: "arrow.triangle.2.circlepath",
                        "Each series is three sets at increasing weight:\n\n• 50% of your 10RM × 5 reps\n• 75% of your 10RM × 5 reps\n• 100% of your 10RM × 5 reps\n\nRest about a minute between sets (while changing plates) and three minutes between series."
                    )

                    section(
                        "Heavy – Light – Medium",
                        icon: "calendar",
                        """
                        Monday — Heavy
                        Do as many full series as you can. This is the main event. Stop when you can barely complete the top set.

                        Wednesday — Light
                        Only the 50% set, repeated for the same number of series you did on Monday. Quick session, aids recovery.

                        Friday — Medium
                        The 50% and 75% sets, repeated for Monday's series count. Building back up for next week's heavy day.
                        """
                    )

                    section(
                        "When to Add Weight",
                        icon: "arrow.up.circle",
                        "When you successfully complete 5 full series on Heavy day, add weight to your 10RM and recalculate all percentages.\n\nBench press: +5 lbs / +2.5 kg\nDeadlift: +10 lbs / +5 kg\n\nStart conservative — a rough 10RM estimate, not a max-effort test."
                    )

                    section(
                        "The Intro Cycle",
                        icon: "leaf",
                        "An optional two-week ramp-up before the main program:\n\nWeek 1 — Only 50% and 75% sets (no heavy singles). Series count: 3 → 4 → 5 across Mon/Wed/Fri.\n\nWeek 2 — Monday adds the 100% set for the first time (2 series). Wednesday does 7 series of 50%+75%. Friday does 5."
                    )

                    section(
                        "Exercise Order",
                        icon: "list.number",
                        "Bench press first, then deadlift — every session. You can switch between them using the tabs during a workout.\n\nThe only acceptable addition is a couple of heavy sets of abdominal work."
                    )

                    section(
                        "Tips",
                        icon: "lightbulb",
                        "• Medium to slow tempo on every rep\n• One second pause at the bottom — chest for bench, floor for deadlift\n• Stay tight, no bouncing\n• Never train to failure\n• You should feel stronger at the end of every workout"
                    )
                }
                .padding()
            }
        }
        .navigationTitle("How It Works")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(_ title: String, icon: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(theme.accentColor)

            Text(body)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 14))
    }
}
