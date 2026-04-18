import Foundation
import SwiftData

@Observable
final class LeaderboardViewModel {
    private(set) var entries: [LeaderboardEntry] = []
    private(set) var currentUserEntry: LeaderboardEntry?
    var selectedTier: LeaderboardEntry.Tier = .gold

    var filteredEntries: [LeaderboardEntry] {
        entries.filter { $0.tier == selectedTier }
    }

    func load(appState: AppState) {
        let weeklyXP = weeklyXP(appState: appState)
        let name = appState.userProgress?.displayName ?? "You"
        entries = LeaderboardRepository.shared.weeklyLeaderboard(userWeeklyXP: weeklyXP, displayName: name)
        currentUserEntry = entries.first(where: \.isCurrentUser)
    }

    private func weeklyXP(appState: AppState) -> Int {
        appState.todaysChallenge?.totalXPEarned ?? 0
    }
}
