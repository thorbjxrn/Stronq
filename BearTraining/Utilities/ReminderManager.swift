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

    var reminderHour: Int = 8 {
        didSet {
            UserDefaults.standard.set(reminderHour, forKey: "reminderHour")
            if isEnabled { scheduleReminders() }
        }
    }

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: "remindersEnabled")
        reminderHour = UserDefaults.standard.object(forKey: "reminderHour") as? Int ?? 8
    }

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func scheduleReminders() {
        cancelAll()

        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Time to train"
        content.body = "Your next workout is waiting."
        content.sound = .default

        let weekdays = [2, 4, 6]
        for weekday in weekdays {
            var dateComponents = DateComponents()
            dateComponents.weekday = weekday
            dateComponents.hour = reminderHour
            dateComponents.minute = 0

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
