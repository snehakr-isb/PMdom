import Foundation

struct LeaderboardEntry: Identifiable {
    let id: UUID
    let rank: Int
    let displayName: String
    let weeklyXP: Int
    let tier: Tier
    let isCurrentUser: Bool

    enum Tier: String, CaseIterable {
        case bronze = "Bronze"
        case silver = "Silver"
        case gold = "Gold"
    }
}

final class LeaderboardRepository {
    static let shared = LeaderboardRepository()
    private init() {}

    func weeklyLeaderboard(userWeeklyXP: Int, displayName: String) -> [LeaderboardEntry] {
        let isoWeek = Calendar.current.component(.weekOfYear, from: Date())
        let isoYear = Calendar.current.component(.year, from: Date())
        var rng = SeededRandomNumberGenerator(seed: UInt64(isoWeek &* 1000 &+ isoYear))

        let opponentNames = [
            "Alex K.", "Jordan M.", "Sam T.", "Riley P.", "Morgan C.",
            "Taylor R.", "Casey L.", "Drew H.", "Quinn B.", "Avery N.",
            "Blake S.", "Charlie W.", "Dakota F.", "Emery G.", "Finley J."
        ]

        var entries: [LeaderboardEntry] = []
        for (i, name) in opponentNames.enumerated() {
            let xp = Int.random(in: 50...500, using: &rng)
            entries.append(LeaderboardEntry(
                id: UUID(seed: "\(isoWeek)\(isoYear)\(i)"),
                rank: 0,
                displayName: name,
                weeklyXP: xp,
                tier: .bronze,
                isCurrentUser: false
            ))
        }
        entries.append(LeaderboardEntry(
            id: UUID(),
            rank: 0,
            displayName: displayName,
            weeklyXP: userWeeklyXP,
            tier: .bronze,
            isCurrentUser: true
        ))

        let sorted = entries.sorted { $0.weeklyXP > $1.weeklyXP }
        return sorted.enumerated().map { (index, entry) in
            let rank = index + 1
            let tier: LeaderboardEntry.Tier = rank <= 5 ? .gold : rank <= 20 ? .silver : .bronze
            return LeaderboardEntry(id: entry.id, rank: rank, displayName: entry.displayName,
                                    weeklyXP: entry.weeklyXP, tier: tier, isCurrentUser: entry.isCurrentUser)
        }
    }
}

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

private extension UUID {
    init(seed: String) {
        var hasher = Hasher()
        hasher.combine(seed)
        let h = abs(hasher.finalize())
        self.init(uuidString: String(format: "%08X-0000-0000-0000-%012X", h & 0xFFFFFFFF, h & 0xFFFFFFFFFFFF)) ?? UUID()
    }
}
