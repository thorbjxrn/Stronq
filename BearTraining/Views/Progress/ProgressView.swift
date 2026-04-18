import SwiftUI
import SwiftData
import Charts

struct ProgressView: View {
    @Environment(ThemeManager.self) private var theme
    @Query(sort: \WorkoutSession.date) private var sessions: [WorkoutSession]
    @Query(sort: \BodyweightEntry.date) private var bodyweightEntries: [BodyweightEntry]
    @Query private var programs: [Program]
    @State private var selectedChart = 0
    @State private var healthKitWeights: [(date: Date, weight: Double)] = []
    @State private var healthKitManager = HealthKitManager()

    private var program: Program? { programs.first }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Picker("Chart", selection: $selectedChart) {
                            Text("Strength").tag(0)
                            Text("Volume").tag(1)
                            Text("Weight").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        switch selectedChart {
                        case 0: strengthChart
                        case 1: volumeChart
                        case 2: bodyweightChart
                        default: EmptyView()
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Progress")
        }
    }

    // MARK: - Strength

    private var strengthChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("10RM Progression")
                .font(.headline)
                .padding(.horizontal)

            let data = strengthData

            if data.isEmpty {
                emptyState("Complete Heavy day workouts to track strength.")
            } else {
                Chart(data, id: \.id) { point in
                    LineMark(
                        x: .value("Week", "W\(point.week)"),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(by: .value("Exercise", point.exercise))
                    .symbol(by: .value("Exercise", point.exercise))
                }
                .chartYAxisLabel(program?.exercises.first?.unit.symbol ?? "kg")
                .frame(height: 250)
                .padding()
                .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Volume

    private var volumeChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Session Volume")
                .font(.headline)
                .padding(.horizontal)

            let completed = sessions.filter(\.isCompleted)

            if completed.isEmpty {
                emptyState("Complete workouts to see volume trends.")
            } else {
                let calendar = Calendar.current
                let grouped = Dictionary(grouping: completed) { session in
                    calendar.startOfDay(for: session.date)
                }
                let volumeData = grouped.map { (day, daySessions) in
                    VolumePoint(
                        id: day.timeIntervalSince1970.description,
                        date: day,
                        volume: daySessions.reduce(0) { $0 + $1.totalVolume },
                        dayType: daySessions.first?.dayType.rawValue ?? ""
                    )
                }.sorted { $0.date < $1.date }

                Chart(volumeData, id: \.id) { point in
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Volume", point.volume)
                    )
                }
                .chartForegroundStyleScale(range: [theme.accentColor])
                .chartYAxisLabel("kg × reps")
                .frame(height: 250)
                .padding()
                .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                // Summary stats
                let totalVol = completed.reduce(0.0) { $0 + $1.totalVolume }
                let avgVol = totalVol / Double(max(completed.count, 1))
                HStack(spacing: 16) {
                    statCard("Total", formatted(totalVol), "kg")
                    statCard("Sessions", "\(completed.count)", "")
                    statCard("Avg/Session", formatted(avgVol), "kg")
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Bodyweight

    private var bodyweightChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Bodyweight")
                    .font(.headline)
                Spacer()
                if healthKitManager.isAvailable {
                    Button {
                        Task {
                            await healthKitManager.requestAuthorization()
                            healthKitWeights = await healthKitManager.readBodyweightHistory()
                        }
                    } label: {
                        Label("Sync Health", systemImage: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(theme.accentColor)
                    }
                }
            }
            .padding(.horizontal)

            let allWeights = mergedBodyweightData

            if allWeights.isEmpty {
                emptyState("Log bodyweight in Settings or sync from Apple Health.")
            } else {
                Chart(allWeights, id: \.id) { point in
                    LineMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(theme.accentColor)

                    PointMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(point.source == "health" ? theme.completedColor : theme.accentColor)
                }
                .chartYAxisLabel("kg")
                .frame(height: 250)
                .padding()
                .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    private var mergedBodyweightData: [BodyweightPoint] {
        var points: [BodyweightPoint] = []

        for entry in bodyweightEntries {
            points.append(BodyweightPoint(
                id: entry.id.uuidString,
                date: entry.date,
                weight: entry.weight,
                source: "manual"
            ))
        }

        for hk in healthKitWeights {
            let isDuplicate = points.contains { abs($0.date.timeIntervalSince(hk.date)) < 86400 && abs($0.weight - hk.weight) < 0.1 }
            if !isDuplicate {
                points.append(BodyweightPoint(
                    id: "hk-\(hk.date.timeIntervalSince1970)",
                    date: hk.date,
                    weight: hk.weight,
                    source: "health"
                ))
            }
        }

        return points.sorted { $0.date < $1.date }
    }

    // MARK: - Helpers

    private func emptyState(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(theme.textSecondary)
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
    }

    private func statCard(_ label: String, _ value: String, _ unit: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
            if !unit.isEmpty {
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(theme.textSecondary)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 10))
    }

    private func formatted(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.0fk", value / 1000)
        }
        return String(format: "%.0f", value)
    }

    private var strengthData: [StrengthPoint] {
        let heavySessions = sessions.filter { $0.isCompleted && $0.dayType == .heavy }
        var points: [StrengthPoint] = []

        for session in heavySessions {
            let names = Set(session.completedSets.map(\.exerciseName))
            for name in names {
                let maxWeight = session.completedSets
                    .filter { $0.exerciseName == name && $0.intensity == 1.0 && $0.isCompleted }
                    .map(\.actualWeight)
                    .max() ?? 0
                if maxWeight > 0 {
                    points.append(StrengthPoint(
                        id: "\(session.weekNumber)-\(name)",
                        week: session.weekNumber,
                        exercise: name,
                        weight: maxWeight
                    ))
                }
            }
        }
        return points.sorted { $0.week < $1.week }
    }
}

struct StrengthPoint: Identifiable {
    let id: String
    let week: Int
    let exercise: String
    let weight: Double
}

struct VolumePoint: Identifiable {
    let id: String
    let date: Date
    let volume: Double
    let dayType: String
}

struct BodyweightPoint: Identifiable {
    let id: String
    let date: Date
    let weight: Double
    let source: String
}
