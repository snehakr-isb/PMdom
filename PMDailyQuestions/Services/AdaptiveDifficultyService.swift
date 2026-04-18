import Foundation
import SwiftData

final class AdaptiveDifficultyService {
    static let shared = AdaptiveDifficultyService()
    private init() {}

    private let evaluationWindow = 20
    private let promoteThreshold = 0.85
    private let demoteThreshold = 0.50
    private let minQuestionsForEvaluation = 10

    func evaluateAndUpdate(
        progress: UserProgress,
        recentAttempts: [QuestionAttempt],
        for category: ContentCategory
    ) {
        let categoryAttempts = recentAttempts
            .filter { $0.category == category.rawValue }
            .suffix(evaluationWindow)

        guard categoryAttempts.count >= minQuestionsForEvaluation else { return }

        let correctCount = categoryAttempts.filter(\.wasCorrect).count
        let accuracy = Double(correctCount) / Double(categoryAttempts.count)
        let current = progress.difficulty(for: category)

        if accuracy > promoteThreshold, let next = current.next {
            progress.setDifficulty(next, for: category)
        } else if accuracy < demoteThreshold, let prev = current.previous {
            progress.setDifficulty(prev, for: category)
        }
    }
}

private extension Difficulty {
    var next: Difficulty? {
        switch self {
        case .beginner: return .intermediate
        case .intermediate: return .advanced
        case .advanced: return nil
        }
    }

    var previous: Difficulty? {
        switch self {
        case .beginner: return nil
        case .intermediate: return .beginner
        case .advanced: return .intermediate
        }
    }
}
