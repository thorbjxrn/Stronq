import Foundation
@preconcurrency import ActivityKit

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
        }
    }

    func updateLiveActivity(timeRemaining: Int) async {
        guard let activity else { return }

        let state = RestTimerAttributes.ContentState(
            timeRemaining: timeRemaining,
            nextSetInfo: activity.content.state.nextSetInfo
        )

        await activity.update(.init(state: state, staleDate: nil))
    }

    func endLiveActivity() async {
        guard let activity else { return }

        let finalState = RestTimerAttributes.ContentState(
            timeRemaining: 0,
            nextSetInfo: "Rest complete"
        )

        await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
        self.activity = nil
    }
}
