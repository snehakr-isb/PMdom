import Foundation
import WidgetKit

struct LeaderboardSnippet: Codable {
    let rank: Int
    let displayName: String
    let weeklyXP: Int
    let isCurrentUser: Bool
}

struct PMWidgetEntry: TimelineEntry {
    let date: Date
    let streakCount: Int
    let freezesAvailable: Int
    let todayXP: Int
    let questionsComplete: Int
    let questionsTotal: Int
    let levelTitle: String
    let totalXP: Int
    let xpToNextLevel: Int
    let leaderboardTop3: [LeaderboardSnippet]
    let isSessionComplete: Bool
    let todayCategoryName: String

    static var placeholder: PMWidgetEntry {
        PMWidgetEntry(
            date: Date(),
            streakCount: 7,
            freezesAvailable: 1,
            todayXP: 75,
            questionsComplete: 4,
            questionsTotal: 10,
            levelTitle: "Senior PM",
            totalXP: 1200,
            xpToNextLevel: 800,
            leaderboardTop3: [
                LeaderboardSnippet(rank: 1, displayName: "Alex K.", weeklyXP: 340, isCurrentUser: false),
                LeaderboardSnippet(rank: 2, displayName: "You", weeklyXP: 280, isCurrentUser: true),
                LeaderboardSnippet(rank: 3, displayName: "Jordan M.", weeklyXP: 210, isCurrentUser: false)
            ],
            isSessionComplete: false,
            todayCategoryName: "Interview Prep"
        )
    }
}
