import Foundation

struct ExerciseAlternative: Identifiable {
    let id: String
    let name: String
    let icon: String

    static let alternatives: [String: [ExerciseAlternative]] = [
        "Bench Press": [
            ExerciseAlternative(id: "db-bench", name: "Dumbbell Bench Press", icon: "dumbbell.fill"),
            ExerciseAlternative(id: "incline-bench", name: "Incline Bench Press", icon: "figure.strengthtraining.traditional"),
            ExerciseAlternative(id: "floor-press", name: "Floor Press", icon: "figure.strengthtraining.traditional"),
            ExerciseAlternative(id: "close-grip-bench", name: "Close-Grip Bench Press", icon: "figure.strengthtraining.traditional"),
        ],
        "Deadlift": [
            ExerciseAlternative(id: "rdl", name: "Romanian Deadlift", icon: "figure.strengthtraining.functional"),
            ExerciseAlternative(id: "sumo", name: "Sumo Deadlift", icon: "figure.strengthtraining.functional"),
            ExerciseAlternative(id: "trap-bar", name: "Trap Bar Deadlift", icon: "figure.strengthtraining.functional"),
        ],
        "Push-up": [
            ExerciseAlternative(id: "dips", name: "Dips", icon: "figure.cooldown"),
            ExerciseAlternative(id: "pike-pushup", name: "Pike Push-up", icon: "figure.push.up"),
            ExerciseAlternative(id: "handstand-pushup", name: "Handstand Push-up", icon: "figure.push.up"),
        ],
        "Zercher Squat": [
            ExerciseAlternative(id: "back-squat", name: "Back Squat", icon: "figure.squat"),
            ExerciseAlternative(id: "front-squat", name: "Front Squat", icon: "figure.squat"),
            ExerciseAlternative(id: "goblet-squat", name: "Goblet Squat", icon: "figure.squat"),
        ],
        "Half-Kneeling Pulldown": [
            ExerciseAlternative(id: "pull-up", name: "Pull-up", icon: "figure.climbing"),
            ExerciseAlternative(id: "lat-pulldown", name: "Lat Pulldown", icon: "figure.rowing"),
            ExerciseAlternative(id: "cable-row", name: "Cable Row", icon: "figure.rowing"),
            ExerciseAlternative(id: "db-row", name: "Dumbbell Row", icon: "figure.rowing"),
        ],
    ]

    static func alternatives(for exerciseName: String) -> [ExerciseAlternative] {
        for (key, alts) in alternatives {
            if key == exerciseName { return alts }
            if alts.contains(where: { $0.name == exerciseName }) {
                var result = alts.filter { $0.name != exerciseName }
                result.insert(ExerciseAlternative(id: key.lowercased(), name: key, icon: ""), at: 0)
                return result
            }
        }
        return []
    }
}
