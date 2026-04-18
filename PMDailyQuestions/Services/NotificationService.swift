import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let dailyReminderID = "pm.daily.reminder"
    private let streakRiskID = "pm.streak.risk"
    private let weeklyResetID = "pm.weekly.reset"

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        guard let granted = try? await center.requestAuthorization(options: [.alert, .badge, .sound]) else {
            return false
        }
        return granted
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderID])

        let content = UNMutableNotificationContent()
        content.title = "PM Daily"
        content.body = "Your daily PM questions are ready. Keep the streak going! 🔥"
        content.sound = .default
        content.badge = 1

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderID, content: content, trigger: trigger)
        center.add(request)
    }

    func scheduleStreakRiskNotificationIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [streakRiskID])

        let content = UNMutableNotificationContent()
        content.title = "Don't lose your streak!"
        content.body = "Complete today's PM challenge before midnight to keep your streak alive."
        content.sound = .default

        var components = DateComponents()
        components.hour = 19
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: streakRiskID, content: content, trigger: trigger)
        center.add(request)
    }

    func scheduleWeeklyLeagueReset() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [weeklyResetID])

        let content = UNMutableNotificationContent()
        content.title = "League resets soon!"
        content.body = "Earn XP in the next 4 hours to climb the ranks before the weekly reset."
        content.sound = .default

        var components = DateComponents()
        components.weekday = 1 // Sunday
        components.hour = 20
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: weeklyResetID, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelStreakRiskNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [streakRiskID])
    }
}
