import Foundation

enum StreakAction {
    case alreadyActiveToday
    case continued
    case savedByFreeze
    case reset
    case started
}

final class StreakService {
    static let shared = StreakService()
    private init() {}

    @discardableResult
    func evaluateOnOpen(streak: Streak) -> StreakAction {
        guard let lastActivity = streak.lastActivityDate else {
            return .started
        }

        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastActivity), to: calendar.startOfDay(for: Date())).day ?? 0

        switch daysDiff {
        case 0:
            return .alreadyActiveToday
        case 1:
            return .continued
        case 2 where streak.freezesAvailable > 0:
            streak.consumeFreeze()
            return .savedByFreeze
        default:
            streak.breakStreak()
            return .reset
        }
    }

    func recordSessionCompletion(streak: Streak) {
        guard !streak.isActiveToday else { return }
        streak.extendStreak()
    }
}
