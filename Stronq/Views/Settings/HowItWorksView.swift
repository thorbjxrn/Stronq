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
                        "A high-volume hypertrophy cycle based on the DeLorme method, developed by Dr. Thomas DeLorme at Harvard Medical School in the 1940s for rehabilitating injured soldiers. The ascending set structure (light → medium → heavy) was later adopted by bodybuilders and strength athletes worldwide for its effectiveness in building muscle."
                    )

                    section(
                        "The Series",
                        icon: "arrow.triangle.2.circlepath",
                        "Each series consists of three ascending sets:\n\n• 50% of your 10RM × 5 reps\n• 75% of your 10RM × 5 reps\n• 100% of your 10RM × 5 reps\n\nRest about a minute between sets (while changing plates) and three minutes between series. The warm-up sets prepare your muscles and nervous system for the heavy set."
                    )

                    section(
                        "Heavy – Light – Medium",
                        icon: "calendar",
                        """
                        The program uses a classic Heavy-Light-Medium weekly structure to manage fatigue and recovery:

                        Heavy day — Full series (all three sets). Do as many series as you can with good form. This is the main growth stimulus.

                        Light day — Only the 50% set, repeated for the same number of series as your heavy day. A brief recovery session.

                        Medium day — The 50% and 75% sets, for the same series count. Builds volume back up without the heavy top set.
                        """
                    )

                    section(
                        "Progressive Overload",
                        icon: "arrow.up.circle",
                        "When you complete 5 full series on your heavy day, increase your 10RM and recalculate all percentages. This is classic progressive overload — small, consistent jumps in weight over time.\n\nStart with a conservative estimate of your 10RM. The program works by building volume at submaximal weights, not by testing your limits."
                    )

                    section(
                        "The Intro Cycle",
                        icon: "leaf",
                        "An optional two-week ramp-up to prepare for the full workload:\n\nWeek 1 — Only 50% and 75% sets (no heavy top set). Series increase across the week: 3 → 4 → 5.\n\nWeek 2 — Heavy day introduces the 100% set for the first time (2 series). Other days continue with higher volume at lighter weights."
                    )

                    section(
                        "Tips",
                        icon: "lightbulb",
                        "• Medium to slow tempo on every rep\n• Pause briefly at the bottom of each rep — stay tight\n• Never train to failure — leave a rep in the bank\n• You should feel stronger at the end of every session\n• Keep the program simple — the magic is in the consistency"
                    )

                    Text("Based on the DeLorme method (1945) with the Heavy-Light-Medium structure popularized in strength training literature.")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                        .padding(.horizontal, 4)
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
