import Foundation
import SwiftData

final class ProgressRepository {
    static let shared = ProgressRepository()
    private init() {}

    func saveAttempt(
        context: ModelContext,
        questionID: UUID,
        category: ContentCategory,
        difficulty: Difficulty,
        wasCorrect: Bool,
        timeSpent: Double,
        xpEarned: Int
    ) {
        let attempt = QuestionAttempt(
            questionID: questionID,
            category: category,
            difficulty: difficulty,
            wasCorrect: wasCorrect,
            timeSpentSeconds: timeSpent,
            xpEarned: xpEarned
        )
        context.insert(attempt)
        try? context.save()
    }

    func recentAttempts(context: ModelContext, limit: Int = 50) -> [QuestionAttempt] {
        var descriptor = FetchDescriptor<QuestionAttempt>(
            sortBy: [SortDescriptor(\.answeredAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? context.fetch(descriptor)) ?? []
    }

    func completedQuestionIDs(context: ModelContext, withinDays days: Int) -> Set<UUID> {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<QuestionAttempt>(
            predicate: #Predicate { $0.answeredAt >= cutoff }
        )
        let attempts = (try? context.fetch(descriptor)) ?? []
        return Set(attempts.compactMap { UUID(uuidString: $0.questionID) })
    }

    func updateSRCard(context: ModelContext, questionID: UUID, wasCorrect: Bool, timeSpent: Double, estimatedSeconds: Int) {
        let idString = questionID.uuidString
        let descriptor = FetchDescriptor<SpacedRepetitionCard>(
            predicate: #Predicate { $0.questionID == idString }
        )
        let card: SpacedRepetitionCard
        if let existing = (try? context.fetch(descriptor))?.first {
            card = existing
        } else {
            card = SpacedRepetitionCard(questionID: questionID)
            context.insert(card)
        }

        let quality = SpacedRepetitionService.shared.qualityScore(
            wasCorrect: wasCorrect,
            timeSpent: timeSpent,
            estimatedSeconds: estimatedSeconds
        )
        let result = SpacedRepetitionService.shared.processReview(card: card, quality: quality)
        SpacedRepetitionService.shared.applyResult(result, to: card)
        try? context.save()
    }

    func dueCards(context: ModelContext) -> [SpacedRepetitionCard] {
        let now = Date()
        let descriptor = FetchDescriptor<SpacedRepetitionCard>(
            predicate: #Predicate { $0.dueDate <= now }
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
