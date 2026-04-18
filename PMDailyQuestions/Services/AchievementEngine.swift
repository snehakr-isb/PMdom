import Foundation
import SwiftData

final class AchievementEngine {
    static let shared = AchievementEngine()
    private init() {}

    func evaluateAfterSession(
        context: ModelContext,
        streak: Streak,
        progress: UserProgress,
        sessionAttempts: [QuestionAttempt],
        allAttempts: [QuestionAttempt],
        consecutiveTimeBonuses: Int
    ) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        let achievements = (try? context.fetch(FetchDescriptor<Achievement>())) ?? []

        func check(_ type: AchievementType, condition: Bool, progressValue: Int, threshold: Int) {
            guard let achievement = achievements.first(where: { $0.typeRaw == type.rawValue }) else {
                let a = Achievement(type: type, threshold: threshold)
                context.insert(a)
                if condition {
                    a.unlock()
                    newlyUnlocked.append(a)
                } else {
                    a.progress = progressValue
                }
                return
            }
            guard !achievement.isUnlocked else { return }
            achievement.progress = progressValue
            if condition {
                achievement.unlock()
                newlyUnlocked.append(achievement)
            }
        }

        check(.streak7, condition: streak.currentCount >= 7, progressValue: streak.currentCount, threshold: 7)
        check(.streak30, condition: streak.currentCount >= 30, progressValue: streak.currentCount, threshold: 30)
        check(.streak100, condition: streak.currentCount >= 100, progressValue: streak.currentCount, threshold: 100)
        check(.firstWin, condition: progress.lifetimeCorrect >= 1, progressValue: progress.lifetimeCorrect, threshold: 1)
        check(.level3, condition: progress.level >= 3, progressValue: progress.level, threshold: 3)

        let sessionCorrect = sessionAttempts.filter(\.wasCorrect).count
        let sessionPerfect = sessionCorrect == sessionAttempts.count && sessionAttempts.count == 10
        check(.perfect10, condition: sessionPerfect, progressValue: sessionCorrect, threshold: 10)

        let frameworkCorrect = allAttempts.filter { $0.category == ContentCategory.pmFrameworks.rawValue && $0.wasCorrect }.count
        check(.frameworks, condition: frameworkCorrect >= 50, progressValue: frameworkCorrect, threshold: 50)

        check(.speedDemon, condition: consecutiveTimeBonuses >= 5, progressValue: consecutiveTimeBonuses, threshold: 5)

        try? context.save()
        return newlyUnlocked
    }
}
