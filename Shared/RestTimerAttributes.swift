import ActivityKit

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
