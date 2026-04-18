import Foundation
import ActivityKit

@Observable
@MainActor
final class TimerManager {
    private var activity: Activity<RestTimerAttributes>?

    func startLiveActivity(
        exerciseName: String,
        nextSetInfo: String,
        duration: Int
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = RestTimerAttributes(exerciseName: exerciseName)
        let state = RestTimerAttributes.ContentState(
            timeRemaining: duration,
            nextSetInfo: nextSetInfo
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            // Live Activity not available
        }
    }

    func updateLiveActivity(timeRemaining: Int) {
        guard let activity else { return }

        let state = RestTimerAttributes.ContentState(
            timeRemaining: timeRemaining,
            nextSetInfo: activity.content.state.nextSetInfo
        )

        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    func endLiveActivity() {
        guard let activity else { return }

        let finalState = RestTimerAttributes.ContentState(
            timeRemaining: 0,
            nextSetInfo: "Rest complete"
        )

        Task {
            await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
        }
        self.activity = nil
    }
}

struct RestTimerAttributes: ActivityAttributes {
    let exerciseName: String

    struct ContentState: Codable, Hashable {
        var timeRemaining: Int
        var nextSetInfo: String

        var formattedTime: String {
            let minutes = timeRemaining / 60
            let seconds = timeRemaining % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
