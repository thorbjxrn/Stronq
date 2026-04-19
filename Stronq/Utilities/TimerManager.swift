import Foundation
@preconcurrency import ActivityKit

@Observable
@MainActor
final class TimerManager {
    private var activityID: String?

    func startLiveActivity(
        exerciseName: String,
        nextSetInfo: String,
        duration: Int
    ) {
        let attrs = RestTimerAttributes(exerciseName: exerciseName)
        let state = RestTimerAttributes.ContentState(
            timeRemaining: duration,
            nextSetInfo: nextSetInfo
        )

        Task {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

            for activity in Activity<RestTimerAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }

            do {
                let newActivity = try Activity.request(
                    attributes: attrs,
                    content: .init(state: state, staleDate: nil),
                    pushType: nil
                )
                activityID = newActivity.id
            } catch {
                print("[LiveActivity] Failed: \(error)")
            }
        }
    }

    func updateLiveActivity(timeRemaining: Int) {
        guard let id = activityID else { return }
        guard let activity = Activity<RestTimerAttributes>.activities.first(where: { $0.id == id }) else { return }

        let state = RestTimerAttributes.ContentState(
            timeRemaining: timeRemaining,
            nextSetInfo: activity.content.state.nextSetInfo
        )

        Task { await activity.update(.init(state: state, staleDate: nil)) }
    }

    func endLiveActivity() {
        activityID = nil

        Task {
            for activity in Activity<RestTimerAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
