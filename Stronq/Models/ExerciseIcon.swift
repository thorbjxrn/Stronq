import Foundation

enum ExerciseIcon {
    private static let icons: [String: String] = [
        "Bench Press": "figure.arms.open",
        "Dumbbell Bench Press": "dumbbell.fill",
        "Incline Bench Press": "dumbbell.fill",
        "Floor Press": "dumbbell.fill",
        "Close-Grip Bench Press": "dumbbell.fill",

        "Deadlift": "figure.strengthtraining.traditional",
        "Romanian Deadlift": "figure.strengthtraining.traditional",
        "Sumo Deadlift": "figure.strengthtraining.traditional",
        "Trap Bar Deadlift": "figure.strengthtraining.traditional",

        "Push-up": "figure.highintensity.intervaltraining",
        "Dips": "figure.highintensity.intervaltraining",

        "Zercher Squat": "figure.cross.training",
        "Back Squat": "figure.cross.training",
        "Front Squat": "figure.cross.training",
        "Goblet Squat": "figure.cross.training",

        "Half-Kneeling Pulldown": "figure.rowing",
        "Seated Cable Row": "figure.rowing",
        "Dumbbell Row": "figure.rowing",
        "Barbell Row": "figure.rowing",
        "Lat Pulldown": "figure.rowing",
    ]

    static func icon(for exerciseName: String) -> String {
        icons[exerciseName] ?? "figure.strengthtraining.traditional"
    }
}
