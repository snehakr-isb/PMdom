import Foundation
import SwiftData

@Observable
final class OnboardingViewModel {
    var selectedCategories: Set<ContentCategory> = Set(ContentCategory.allCases)
    var dailyGoal: Int = 10
    var displayName: String = ""
    var notificationHour: Int = 8
    var notificationMinute: Int = 0
    var notificationPermissionGranted: Bool = false

    func completeOnboarding(context: ModelContext) async {
        let name = displayName.isEmpty ? "PM Learner" : displayName
        let progress = UserProgress(displayName: name)
        context.insert(progress)
        context.insert(Streak())

        if notificationPermissionGranted {
            await requestAndScheduleNotifications()
        }

        try? context.save()
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    func requestNotificationPermission() async {
        notificationPermissionGranted = await NotificationService.shared.requestPermission()
    }

    private func requestAndScheduleNotifications() async {
        NotificationService.shared.scheduleDailyReminder(hour: notificationHour, minute: notificationMinute)
        NotificationService.shared.scheduleWeeklyLeagueReset()
    }
}
