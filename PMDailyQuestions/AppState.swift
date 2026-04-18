import Foundation
import SwiftUI
import SwiftData

@Observable
final class AppState {
    var streak: Streak?
    var userProgress: UserProgress?
    var todaysChallenge: DailyChallenge?
    var navigationPath = NavigationPath()
    var activeTab: Tab = .home
    var newlyUnlockedAchievements: [Achievement] = []
    var showAchievementBanner = false

    enum Tab: Hashable {
        case home, learn, leaderboard, profile, settings
    }

    var streakCount: Int { streak?.currentCount ?? 0 }
    var isActiveToday: Bool { streak?.isActiveToday ?? false }
    var totalXP: Int { userProgress?.totalXP ?? 0 }
    var levelTitle: String { userProgress?.levelTitle ?? "PM Recruit" }
    var level: Int { userProgress?.level ?? 1 }
    var todayProgressFraction: Double { todaysChallenge?.progressFraction ?? 0 }
    var todayQuestionsComplete: Int { todaysChallenge?.completedCount ?? 0 }
    var todayQuestionsTotal: Int { todaysChallenge?.totalCount ?? 10 }

    func loadState(from context: ModelContext) {
        let streakDescriptor = FetchDescriptor<Streak>()
        let progressDescriptor = FetchDescriptor<UserProgress>()

        streak = (try? context.fetch(streakDescriptor))?.first
        userProgress = (try? context.fetch(progressDescriptor))?.first

        if streak == nil {
            let newStreak = Streak()
            context.insert(newStreak)
            streak = newStreak
        }

        if userProgress == nil {
            let newProgress = UserProgress()
            context.insert(newProgress)
            userProgress = newProgress
        }

        let today = Calendar.current.startOfDay(for: Date())
        let challengeDescriptor = FetchDescriptor<DailyChallenge>(
            predicate: #Predicate { $0.date == today }
        )
        todaysChallenge = (try? context.fetch(challengeDescriptor))?.first

        try? context.save()
    }

    func triggerAchievementBanner(for achievements: [Achievement]) {
        guard !achievements.isEmpty else { return }
        newlyUnlockedAchievements = achievements
        showAchievementBanner = true
    }
}
