import Foundation
import SwiftData

@Model
final class UserProgress {
    var totalXP: Int
    var lifetimeAnswered: Int
    var lifetimeCorrect: Int
    var displayName: String
    var avatarSeed: String
    var categoryDifficulties: [String: String]

    init(displayName: String = "PM Learner") {
        self.totalXP = 0
        self.lifetimeAnswered = 0
        self.lifetimeCorrect = 0
        self.displayName = displayName
        self.avatarSeed = UUID().uuidString
        self.categoryDifficulties = [:]
    }

    var level: Int {
        switch totalXP {
        case 0..<200: return 1
        case 200..<500: return 2
        case 500..<1000: return 3
        case 1000..<2000: return 4
        case 2000..<4000: return 5
        case 4000..<8000: return 6
        default: return 7
        }
    }

    var levelTitle: String {
        switch level {
        case 1: return "PM Recruit"
        case 2: return "Associate PM"
        case 3: return "PM"
        case 4: return "Senior PM"
        case 5: return "Staff PM"
        case 6: return "Principal PM"
        default: return "PM Legend"
        }
    }

    var xpForCurrentLevel: Int {
        let thresholds = [0, 200, 500, 1000, 2000, 4000, 8000]
        let lvl = min(level - 1, thresholds.count - 1)
        return totalXP - thresholds[lvl]
    }

    var xpToNextLevel: Int {
        let thresholds = [200, 300, 500, 1000, 2000, 4000, Int.max]
        return thresholds[min(level - 1, thresholds.count - 1)]
    }

    var accuracy: Double {
        guard lifetimeAnswered > 0 else { return 0 }
        return Double(lifetimeCorrect) / Double(lifetimeAnswered)
    }

    func difficulty(for category: ContentCategory) -> Difficulty {
        guard let raw = categoryDifficulties[category.rawValue],
              let difficulty = Difficulty(rawValue: raw) else {
            return .beginner
        }
        return difficulty
    }

    func setDifficulty(_ difficulty: Difficulty, for category: ContentCategory) {
        categoryDifficulties[category.rawValue] = difficulty.rawValue
    }

    func addXP(_ xp: Int) {
        totalXP += xp
    }

    func recordAttempt(wasCorrect: Bool) {
        lifetimeAnswered += 1
        if wasCorrect { lifetimeCorrect += 1 }
    }
}
