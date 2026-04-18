import Foundation
import SwiftData

final class DailyMixService {
    static let shared = DailyMixService()
    private init() {}

    private let sessionSize = 10
    private let maxSRSlots = 3

    func buildDailyMix(
        allQuestions: [Question],
        dueCards: [SpacedRepetitionCard],
        recentlyCompletedIDs: Set<UUID>,
        progress: UserProgress
    ) -> [Question] {
        var result: [Question] = []
        let available = allQuestions.filter { !recentlyCompletedIDs.contains($0.id) }

        // Spaced repetition priority slots
        let dueQuestionIDs = Set(dueCards.prefix(maxSRSlots).map { UUID(uuidString: $0.questionID) }.compactMap { $0 })
        let srQuestions = available.filter { dueQuestionIDs.contains($0.id) }
        result.append(contentsOf: srQuestions.prefix(maxSRSlots))

        let remaining = sessionSize - result.count
        let ratios: [(ContentCategory, Double)] = [
            (.interviewPrep, 0.40),
            (.pmFrameworks, 0.30),
            (.currentEvents, 0.20),
            (.aiTechFundamentals, 0.10)
        ]

        let usedIDs = Set(result.map(\.id))
        let srIDs = dueQuestionIDs

        for (category, ratio) in ratios {
            let slots = max(1, Int(Double(remaining) * ratio))
            let difficulty = progress.difficulty(for: category)
            let pool = available.filter {
                $0.category == category &&
                $0.difficulty == difficulty &&
                !usedIDs.contains($0.id) &&
                !srIDs.contains($0.id)
            }
            let fallback = available.filter {
                $0.category == category &&
                !usedIDs.contains($0.id) &&
                !srIDs.contains($0.id)
            }
            let source = pool.isEmpty ? fallback : pool
            result.append(contentsOf: source.shuffled().prefix(slots))
        }

        // Top up if we're short
        if result.count < sessionSize {
            let usedNow = Set(result.map(\.id))
            let topUp = available
                .filter { !usedNow.contains($0.id) }
                .shuffled()
                .prefix(sessionSize - result.count)
            result.append(contentsOf: topUp)
        }

        return Array(result.prefix(sessionSize).shuffled())
    }
}
