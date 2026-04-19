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
            ExerciseAlternative(id: "pike-pushup", name: "Pike Push-up", icon: "figure.core.training"),
            ExerciseAlternative(id: "handstand-pushup", name: "Handstand Push-up", icon: "figure.core.training"),
        ],
        "Zercher Squat": [
            ExerciseAlternative(id: "back-squat", name: "Back Squat", icon: "figure.strengthtraining.functional"),
            ExerciseAlternative(id: "front-squat", name: "Front Squat", icon: "figure.strengthtraining.functional"),
            ExerciseAlternative(id: "goblet-squat", name: "Goblet Squat", icon: "figure.strengthtraining.functional"),
        ],
        "Half-Kneeling Pulldown": [
            ExerciseAlternative(id: "seated-cable-row", name: "Seated Cable Row", icon: "figure.rowing"),
            ExerciseAlternative(id: "db-row", name: "Dumbbell Row", icon: "figure.rowing"),
            ExerciseAlternative(id: "barbell-row", name: "Barbell Row", icon: "figure.rowing"),
            ExerciseAlternative(id: "lat-pulldown", name: "Lat Pulldown", icon: "figure.rowing"),
        ],
    ]

    static func alternatives(for exerciseName: String) -> [ExerciseAlternative] {
        let name = exerciseName.lowercased()
        for (key, alts) in alternatives {
            let keyMatch = key.lowercased() == name || name.contains(key.lowercased().prefix(4))
            let altMatch = alts.contains { $0.name.lowercased() == name }

            if keyMatch {
                return alts
            }
            if altMatch {
                var result = alts.filter { $0.name.lowercased() != name }
                result.insert(ExerciseAlternative(id: key.lowercased(), name: key, icon: "figure.strengthtraining.traditional"), at: 0)
                return result
            }
        }
        return []
    }
}
