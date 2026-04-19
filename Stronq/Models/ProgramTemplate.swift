import Foundation

struct ProgramTemplate: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let exercises: [TemplateExercise]

    struct TemplateExercise {
        let name: String
        let type: ExerciseType
        let defaultRM: Double
        let defaultRMLbs: Double
        let increment: Double
        let incrementLbs: Double
        let icon: String
    }

    static let classic = ProgramTemplate(
        id: "classic",
        name: "Classic",
        subtitle: "Bench Press + Deadlift",
        exercises: [
            TemplateExercise(
                name: "Bench Press",
                type: .weighted,
                defaultRM: 60, defaultRMLbs: 135,
                increment: 2.5, incrementLbs: 5,
                icon: "figure.strengthtraining.traditional"
            ),
            TemplateExercise(
                name: "Deadlift",
                type: .weighted,
                defaultRM: 80, defaultRMLbs: 175,
                increment: 5, incrementLbs: 10,
                icon: "figure.strengthtraining.functional"
            )
        ]
    )

    static let bear = ProgramTemplate(
        id: "bear",
        name: "Yolked",
        subtitle: "Push-up + Zercher Squat + HK Pulldown",
        exercises: [
            TemplateExercise(
                name: "Push-up",
                type: .bodyweight,
                defaultRM: 0, defaultRMLbs: 0,
                increment: 0, incrementLbs: 0,
                icon: "figure.push.up"
            ),
            TemplateExercise(
                name: "Zercher Squat",
                type: .weighted,
                defaultRM: 45, defaultRMLbs: 95,
                increment: 5, incrementLbs: 10,
                icon: "figure.squat"
            ),
            TemplateExercise(
                name: "Half-Kneeling Pulldown",
                type: .weighted,
                defaultRM: 25, defaultRMLbs: 55,
                increment: 2.5, incrementLbs: 5,
                icon: "figure.rowing"
            )
        ]
    )

    static let all: [ProgramTemplate] = [classic, bear]
}
