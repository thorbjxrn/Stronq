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
        let endDate = Date.now.addingTimeInterval(TimeInterval(duration))
        let state = RestTimerAttributes.ContentState(
            endDate: endDate,
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
                    content: .init(state: state, staleDate: endDate),
                    pushType: nil
                )
                activityID = newActivity.id
            } catch {}
        }
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
