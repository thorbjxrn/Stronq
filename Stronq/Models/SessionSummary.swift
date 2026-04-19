import Foundation

struct SessionSummary {
    let dayType: DayType
    let duration: String
    let seriesCount: Int
    let volume: Double

    init(session: WorkoutSession) {
        self.dayType = session.dayType
        let mins = Int(session.duration) / 60
        let secs = Int(session.duration) % 60
        self.duration = "\(mins):\(String(format: "%02d", secs))"
        self.seriesCount = session.completedSets.map(\.seriesNumber).max() ?? 0
        self.volume = session.totalVolume
    }
}
