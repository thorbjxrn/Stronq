import Foundation

struct ExerciseAlternative: Identifiable, Sendable {
    let id: String
    let name: String
    var isWeighted: Bool = true
    var defaultRM: Double = 0
    var defaultIncrement: Double = 2.5
    var isFree: Bool = false

    static let alternatives: [String: [ExerciseAlternative]] = [
        "Bench Press": [
            ExerciseAlternative(id: "db-bench", name: "Dumbbell Bench Press", defaultRM: 20, defaultIncrement: 2, isFree: true),
            ExerciseAlternative(id: "incline-bench", name: "Incline Bench Press", defaultRM: 50),
            ExerciseAlternative(id: "floor-press", name: "Floor Press", defaultRM: 50),
            ExerciseAlternative(id: "close-grip-bench", name: "Close-Grip Bench Press", defaultRM: 50),
        ],
        "Deadlift": [
            ExerciseAlternative(id: "rdl", name: "Romanian Deadlift", defaultRM: 60),
            ExerciseAlternative(id: "sumo", name: "Sumo Deadlift", defaultRM: 80),
            ExerciseAlternative(id: "trap-bar", name: "Trap Bar Deadlift", defaultRM: 80),
        ],
        "Push-up": [
            ExerciseAlternative(id: "dips", name: "Dips", defaultRM: 0, defaultIncrement: 5),
            ExerciseAlternative(id: "db-bench-alt", name: "Dumbbell Bench Press", defaultRM: 20, defaultIncrement: 2),
            ExerciseAlternative(id: "bench-press-alt", name: "Bench Press", defaultRM: 60),
        ],
        "Zercher Squat": [
            ExerciseAlternative(id: "back-squat", name: "Back Squat", defaultRM: 60),
            ExerciseAlternative(id: "front-squat", name: "Front Squat", defaultRM: 50),
            ExerciseAlternative(id: "goblet-squat", name: "Goblet Squat", defaultRM: 24, defaultIncrement: 2),
        ],
        "Half-Kneeling Pulldown": [
            ExerciseAlternative(id: "seated-cable-row", name: "Seated Cable Row", defaultRM: 40),
            ExerciseAlternative(id: "db-row", name: "Dumbbell Row", defaultRM: 20, defaultIncrement: 2),
            ExerciseAlternative(id: "barbell-row", name: "Barbell Row", defaultRM: 40),
            ExerciseAlternative(id: "lat-pulldown", name: "Lat Pulldown", defaultRM: 40),
        ],
    ]

    private static let aliases: [String: String] = [
        "HK Pulldown": "Half-Kneeling Pulldown",
    ]

    static func alternatives(for exerciseName: String) -> [ExerciseAlternative] {
        let canonicalName = aliases[exerciseName] ?? exerciseName

        if let alts = alternatives[canonicalName] {
            return alts
        }

        for (key, alts) in alternatives {
            if alts.contains(where: { $0.name == canonicalName }) {
                var result = alts.filter { $0.name != canonicalName }
                let isBodyweight = key == "Push-up"
                result.insert(ExerciseAlternative(id: key.lowercased(), name: key, isWeighted: !isBodyweight, defaultRM: 0, isFree: true), at: 0)
                return result
            }
        }
        return []
    }
}
