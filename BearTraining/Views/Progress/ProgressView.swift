import SwiftUI
import SwiftData
import Charts

struct ProgressView: View {
    @Environment(ThemeManager.self) private var theme
    @Query(sort: \WorkoutSession.date) private var sessions: [WorkoutSession]
    @Query(sort: \BodyweightEntry.date) private var bodyweightEntries: [BodyweightEntry]
    @State private var selectedChart = 0

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

    // MARK: - Strength Chart

    private var strengthChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("10RM Progression")
                .font(.headline)
                .padding(.horizontal)

            let data = strengthData

            if data.isEmpty {
                emptyState("Complete workouts to see strength progress.")
            } else {
                Chart(data, id: \.id) { point in
                    LineMark(
                        x: .value("Week", point.week),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(by: .value("Exercise", point.exercise))

                    PointMark(
                        x: .value("Week", point.week),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(by: .value("Exercise", point.exercise))
                }
                .chartYAxisLabel("kg")
                .frame(height: 250)
                .padding()
                .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Volume Chart

    private var volumeChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Session Volume")
                .font(.headline)
                .padding(.horizontal)

            let completedSessions = sessions.filter(\.isCompleted)

            if completedSessions.isEmpty {
                emptyState("Complete workouts to see volume trends.")
            } else {
                Chart(completedSessions) { session in
                    BarMark(
                        x: .value("Date", session.date, unit: .day),
                        y: .value("Volume", session.totalVolume)
                    )
                    .foregroundStyle(theme.accentColor.gradient)
                }
                .chartYAxisLabel("kg × reps")
                .frame(height: 250)
                .padding()
                .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Bodyweight Chart

    private var bodyweightChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bodyweight")
                .font(.headline)
                .padding(.horizontal)

            if bodyweightEntries.isEmpty {
                emptyState("Log your bodyweight in Settings to track it here.")
            } else {
                Chart(bodyweightEntries) { entry in
                    LineMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(theme.accentColor)

                    PointMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(theme.accentColor)
                }
                .chartYAxisLabel("kg")
                .frame(height: 250)
                .padding()
                .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    private func emptyState(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(theme.textSecondary)
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
    }

    // MARK: - Data

    private var strengthData: [StrengthPoint] {
        let heavySessions = sessions.filter { $0.isCompleted && $0.dayType == .heavy }
        var points: [StrengthPoint] = []

        for session in heavySessions {
            let exerciseNames = Set(session.completedSets.map(\.exerciseName))
            for name in exerciseNames {
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
