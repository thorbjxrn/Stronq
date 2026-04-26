import Foundation

struct SessionSummary: Sendable {
    let dayName: String
    let duration: String
    let groupCounts: [Int]
    let volume: Double

    var totalGroups: Int { groupCounts.reduce(0, +) }

    init(dayName: String, elapsed: TimeInterval, volume: Double, groupCounts: [Int]) {
        self.dayName = dayName
        let mins = Int(elapsed) / 60
        let secs = Int(elapsed) % 60
        self.duration = "\(mins):\(String(format: "%02d", secs))"
        self.volume = volume
        self.groupCounts = groupCounts
    }
}
