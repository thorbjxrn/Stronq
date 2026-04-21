import ActivityKit
import WidgetKit
import SwiftUI

struct StronqLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestTimerAttributes.self) { context in
            // Lock screen banner
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Stronq")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                    Text(timerInterval: context.state.timerInterval, countsDown: true)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.85, green: 0.75, blue: 0.55))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(context.attributes.exerciseName)
                        .font(.subheadline.bold())
                    Text(context.state.nextSetInfo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .activityBackgroundTint(.black)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(timerInterval: context.state.timerInterval, countsDown: true)
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .foregroundStyle(Color(red: 0.85, green: 0.75, blue: 0.55))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.exerciseName)
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.nextSetInfo)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Text(timerInterval: context.state.timerInterval, countsDown: true)
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(Color(red: 0.85, green: 0.75, blue: 0.55))
            } compactTrailing: {
                Image(systemName: "timer")
                    .foregroundStyle(Color(red: 0.85, green: 0.75, blue: 0.55))
            } minimal: {
                Text(timerInterval: context.state.timerInterval, countsDown: true)
                    .font(.system(.caption2, design: .monospaced))
            }
        }
    }
}
