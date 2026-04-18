import Foundation

struct ExerciseTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let type: ExerciseType
    let category: ExerciseCategory
    let defaultIncrement: Double
    let icon: String

    enum ExerciseCategory: String, CaseIterable {
        case push = "Push"
        case pull = "Pull"
        case legs = "Legs"
    }

    static let catalog: [ExerciseTemplate] = [
        // Push
        ExerciseTemplate(id: "bench-press", name: "Bench Press", type: .weighted, category: .push, defaultIncrement: 2.5, icon: "figure.strengthtraining.traditional"),
        ExerciseTemplate(id: "push-up", name: "Push-up", type: .bodyweight, category: .push, defaultIncrement: 0, icon: "figure.push.up"),
        ExerciseTemplate(id: "overhead-press", name: "Overhead Press", type: .weighted, category: .push, defaultIncrement: 2.5, icon: "figure.arms.open"),
        ExerciseTemplate(id: "dumbbell-press", name: "Dumbbell Press", type: .weighted, category: .push, defaultIncrement: 2, icon: "dumbbell.fill"),
        ExerciseTemplate(id: "dips", name: "Dips", type: .bodyweight, category: .push, defaultIncrement: 0, icon: "figure.cooldown"),

        // Pull
        ExerciseTemplate(id: "deadlift", name: "Deadlift", type: .weighted, category: .pull, defaultIncrement: 5, icon: "figure.strengthtraining.functional"),
        ExerciseTemplate(id: "pulldown", name: "Half-Kneeling 1-Arm Pulldown", type: .weighted, category: .pull, defaultIncrement: 2.5, icon: "figure.rowing"),
        ExerciseTemplate(id: "barbell-row", name: "Barbell Row", type: .weighted, category: .pull, defaultIncrement: 2.5, icon: "figure.rowing"),
        ExerciseTemplate(id: "pull-up", name: "Pull-up", type: .bodyweight, category: .pull, defaultIncrement: 0, icon: "figure.climbing"),
        ExerciseTemplate(id: "cable-row", name: "Cable Row", type: .weighted, category: .pull, defaultIncrement: 2.5, icon: "figure.rowing"),

        // Legs
        ExerciseTemplate(id: "zercher-squat", name: "Zercher Squat", type: .weighted, category: .legs, defaultIncrement: 5, icon: "figure.squat"),
        ExerciseTemplate(id: "back-squat", name: "Back Squat", type: .weighted, category: .legs, defaultIncrement: 5, icon: "figure.squat"),
        ExerciseTemplate(id: "front-squat", name: "Front Squat", type: .weighted, category: .legs, defaultIncrement: 5, icon: "figure.squat"),
        ExerciseTemplate(id: "leg-press", name: "Leg Press", type: .weighted, category: .legs, defaultIncrement: 5, icon: "figure.step.training"),
        ExerciseTemplate(id: "romanian-deadlift", name: "Romanian Deadlift", type: .weighted, category: .legs, defaultIncrement: 5, icon: "figure.strengthtraining.functional"),
    ]

    static let v1Defaults: [String] = ["push-up", "pulldown", "zercher-squat"]
    static let originalDefaults: [String] = ["bench-press", "deadlift"]
}
