import Foundation
import SwiftData

@Model
final class Streak {
    var currentCount: Int
    var longestCount: Int
    var lastActivityDate: Date?
    var freezesAvailable: Int
    var totalActiveDays: Int

    init() {
        self.currentCount = 0
        self.longestCount = 0
        self.lastActivityDate = nil
        self.freezesAvailable = 0
        self.totalActiveDays = 0
    }

    var isActiveToday: Bool {
        guard let last = lastActivityDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    func extendStreak() {
        currentCount += 1
        totalActiveDays += 1
        longestCount = max(longestCount, currentCount)
        lastActivityDate = Date()
        if currentCount == 7 || currentCount == 30 || currentCount == 100 {
            freezesAvailable = min(freezesAvailable + 1, 2)
        }
    }

    func breakStreak() {
        currentCount = 0
    }

    func consumeFreeze() {
        guard freezesAvailable > 0 else { return }
        freezesAvailable -= 1
        lastActivityDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    }
}
