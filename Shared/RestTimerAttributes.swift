import ActivityKit
import Foundation

struct RestTimerAttributes: ActivityAttributes {
    let exerciseName: String

    struct ContentState: Codable, Hashable {
        var endDate: Date
        var nextSetInfo: String

        var timerInterval: ClosedRange<Date> {
            Date.now...endDate
        }
    }
}
