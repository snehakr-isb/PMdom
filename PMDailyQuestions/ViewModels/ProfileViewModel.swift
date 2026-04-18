import Foundation
import SwiftData

@Observable
final class ProfileViewModel {
    private(set) var achievements: [Achievement] = []
    private(set) var recentAttempts: [QuestionAttempt] = []
    private(set) var categoryAccuracy: [ContentCategory: Double] = [:]

    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<Achievement>()
        achievements = (try? context.fetch(descriptor)) ?? []

        recentAttempts = ProgressRepository.shared.recentAttempts(context: context, limit: 100)
        computeCategoryAccuracy()
    }

    private func computeCategoryAccuracy() {
        for category in ContentCategory.allCases {
            let attempts = recentAttempts.filter { $0.category == category.rawValue }
            guard !attempts.isEmpty else { continue }
            let correct = attempts.filter(\.wasCorrect).count
            categoryAccuracy[category] = Double(correct) / Double(attempts.count)
        }
    }

    var unlockedAchievements: [Achievement] { achievements.filter(\.isUnlocked) }
    var lockedAchievements: [Achievement] { achievements.filter { !$0.isUnlocked } }
}
