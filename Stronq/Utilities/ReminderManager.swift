import UserNotifications
import SwiftUI

@Observable
@MainActor
final class ReminderManager {
    var isEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "remindersEnabled")
            if isEnabled {
                scheduleReminders()
            } else {
                cancelAll()
            }
        }
    }

    var reminderTime: Date {
        didSet {
            UserDefaults.standard.set(reminderTime.timeIntervalSince1970, forKey: "reminderTime")
            if isEnabled { scheduleReminders() }
        }
    }

    var reminderDays: Set<Int> {
        didSet {
            UserDefaults.standard.set(Array(reminderDays), forKey: "reminderDays")
            if isEnabled { scheduleReminders() }
        }
    }

    static let dayNames: [(id: Int, short: String)] = [
        (2, "Mon"), (3, "Tue"), (4, "Wed"), (5, "Thu"), (6, "Fri"), (7, "Sat"), (1, "Sun")
    ]

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: "remindersEnabled")

        if let ts = UserDefaults.standard.object(forKey: "reminderTime") as? TimeInterval {
            reminderTime = Date(timeIntervalSince1970: ts)
        } else {
            var components = DateComponents()
            components.hour = 8
            components.minute = 0
            reminderTime = Calendar.current.date(from: components) ?? .now
        }

        if let days = UserDefaults.standard.array(forKey: "reminderDays") as? [Int] {
            reminderDays = Set(days)
        } else {
            reminderDays = [2, 4, 6]
        }
    }

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleReminders() {
        cancelAll()

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminderTime)
        let minute = calendar.component(.minute, from: reminderTime)

        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Time to train"
        content.body = "Your next workout is waiting."
        content.sound = .default

        for weekday in reminderDays {
            var dateComponents = DateComponents()
            dateComponents.weekday = weekday
            dateComponents.hour = hour
            dateComponents.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "workout-\(weekday)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
