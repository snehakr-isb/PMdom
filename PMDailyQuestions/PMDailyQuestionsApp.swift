import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct PMDailyQuestionsApp: App {
    @State private var appState = AppState()
    private let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(persistence.container)
                .environment(appState)
                .onAppear {
                    registerBackgroundTasks()
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == SharedConstants.deepLinkScheme else { return }
        switch url.host {
        case "start-session":
            appState.activeTab = .home
        case "leaderboard":
            appState.activeTab = .leaderboard
        default:
            break
        }
    }

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.pmquestions.streak-check",
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            NotificationService.shared.scheduleStreakRiskNotificationIfNeeded()
            refreshTask.setTaskCompleted(success: true)
            scheduleStreakCheck()
        }
        scheduleStreakCheck()
    }

    private func scheduleStreakCheck() {
        let request = BGAppRefreshTaskRequest(identifier: "com.pmquestions.streak-check")
        request.earliestBeginDate = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())
        try? BGTaskScheduler.shared.submit(request)
    }
}
