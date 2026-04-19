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

        // End existing
        if let existing = activity {
            let a = existing
            activity = nil
            Task { await a.end(nil, dismissalPolicy: .immediate) }
        }

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
            print("[LiveActivity] Failed: \(error)")
        }
    }

    func updateLiveActivity(timeRemaining: Int) {
        guard let activity else { return }

        let state = RestTimerAttributes.ContentState(
            timeRemaining: timeRemaining,
            nextSetInfo: activity.content.state.nextSetInfo
        )

        let a = activity
        Task { await a.update(.init(state: state, staleDate: nil)) }
    }

    func endLiveActivity() {
        guard let activity else { return }
        let a = activity
        self.activity = nil
        Task { await a.end(nil, dismissalPolicy: .immediate) }
    }
}
