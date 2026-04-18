import WidgetKit
import SwiftUI
import SwiftData

struct PMWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PMWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PMWidgetEntry) -> Void) {
        completion(context.isPreview ? .placeholder : fetchEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PMWidgetEntry>) -> Void) {
        let entry = fetchEntry()
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func fetchEntry() -> PMWidgetEntry {
        guard let container = try? makeContainer() else { return .placeholder }
        let context = ModelContext(container)

        let today = Calendar.current.startOfDay(for: Date())
        let challengeDescriptor = FetchDescriptor<DailyChallenge>(
            predicate: #Predicate { $0.date == today }
        )
        let challenge = (try? context.fetch(challengeDescriptor))?.first

        let progressDescriptor = FetchDescriptor<UserProgress>()
        let progress = (try? context.fetch(progressDescriptor))?.first

        let streakDescriptor = FetchDescriptor<Streak>()
        let streak = (try? context.fetch(streakDescriptor))?.first

        let leaderboard = LeaderboardRepository.shared.weeklyLeaderboard(
            userWeeklyXP: challenge?.totalXPEarned ?? 0,
            displayName: progress?.displayName ?? "You"
        ).prefix(3).map {
            LeaderboardSnippet(rank: $0.rank, displayName: $0.displayName,
                               weeklyXP: $0.weeklyXP, isCurrentUser: $0.isCurrentUser)
        }

        return PMWidgetEntry(
            date: Date(),
            streakCount: streak?.currentCount ?? 0,
            freezesAvailable: streak?.freezesAvailable ?? 0,
            todayXP: challenge?.totalXPEarned ?? 0,
            questionsComplete: challenge?.completedCount ?? 0,
            questionsTotal: challenge?.totalCount ?? 10,
            levelTitle: progress?.levelTitle ?? "PM Recruit",
            totalXP: progress?.totalXP ?? 0,
            xpToNextLevel: progress?.xpToNextLevel ?? 200,
            leaderboardTop3: Array(leaderboard),
            isSessionComplete: challenge?.isComplete ?? false,
            todayCategoryName: "Daily Mix"
        )
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([DailyChallenge.self, UserProgress.self, Streak.self])
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: SharedConstants.appGroupID
        ) else { throw NSError(domain: "Widget", code: 1) }
        let storeURL = groupURL.appendingPathComponent("pmdaily.store")
        let config = ModelConfiguration(schema: schema, url: storeURL, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: config)
    }
}
