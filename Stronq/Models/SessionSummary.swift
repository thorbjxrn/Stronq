import Foundation

struct SessionSummary {
    let dayType: DayType
    let duration: String
    let seriesCounts: [Int]
    let volume: Double

    var totalSeries: Int { seriesCounts.reduce(0, +) }

    init(dayType: DayType, elapsed: TimeInterval, volume: Double, seriesCounts: [Int]) {
        self.dayType = dayType
        let mins = Int(elapsed) / 60
        let secs = Int(elapsed) % 60
        self.duration = "\(mins):\(String(format: "%02d", secs))"
        self.volume = volume
        self.seriesCounts = seriesCounts
    }
}
