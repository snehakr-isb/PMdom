import Foundation
import SwiftData

enum AchievementType: String, Codable, CaseIterable {
    case streak7 = "STREAK_7"
    case streak30 = "STREAK_30"
    case streak100 = "STREAK_100"
    case firstWin = "FIRST_WIN"
    case perfect10 = "PERFECT_10"
    case frameworks = "FRAMEWORKS"
    case speedDemon = "SPEED_DEMON"
    case level3 = "LEVEL_3"
    case comeback = "COMEBACK"

    var title: String {
        switch self {
        case .streak7: return "Week Warrior"
        case .streak30: return "Monthly Grinder"
        case .streak100: return "Centurion"
        case .firstWin: return "First Blood"
        case .perfect10: return "Perfect 10"
        case .frameworks: return "Framework Fluent"
        case .speedDemon: return "Speed Demon"
        case .level3: return "Climbing the Ladder"
        case .comeback: return "Comeback Kid"
        }
    }

    var description: String {
        switch self {
        case .streak7: return "Complete a 7-day streak"
        case .streak30: return "Complete a 30-day streak"
        case .streak100: return "Complete a 100-day streak"
        case .firstWin: return "Answer your first question correctly"
        case .perfect10: return "Get 10/10 accuracy in a single session"
        case .frameworks: return "Answer 50 framework questions correctly"
        case .speedDemon: return "Earn time bonuses on 5 questions in a row"
        case .level3: return "Reach Level 3 (PM)"
        case .comeback: return "Return after a 7+ day absence"
        }
    }

    var iconName: String {
        switch self {
        case .streak7: return "flame"
        case .streak30: return "flame.fill"
        case .streak100: return "trophy.fill"
        case .firstWin: return "star.fill"
        case .perfect10: return "checkmark.seal.fill"
        case .frameworks: return "book.fill"
        case .speedDemon: return "bolt.fill"
        case .level3: return "arrow.up.circle.fill"
        case .comeback: return "arrow.counterclockwise.circle.fill"
        }
    }
}

@Model
final class Achievement {
    var typeRaw: String
    var unlockedAt: Date?
    var progress: Int
    var threshold: Int

    init(type: AchievementType, threshold: Int) {
        self.typeRaw = type.rawValue
        self.unlockedAt = nil
        self.progress = 0
        self.threshold = threshold
    }

    var type: AchievementType? { AchievementType(rawValue: typeRaw) }
    var isUnlocked: Bool { unlockedAt != nil }
    var progressFraction: Double {
        guard threshold > 0 else { return isUnlocked ? 1 : 0 }
        return min(Double(progress) / Double(threshold), 1.0)
    }

    func unlock() {
        guard unlockedAt == nil else { return }
        unlockedAt = Date()
        progress = threshold
    }
}
