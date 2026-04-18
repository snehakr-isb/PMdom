import Foundation

struct SM2Result {
    let newInterval: Int
    let newEaseFactor: Double
    let newRepetitions: Int
    let nextDueDate: Date
}

final class SpacedRepetitionService {
    static let shared = SpacedRepetitionService()
    private init() {}

    // quality: 1 = wrong, 3 = correct+slow, 5 = correct+fast
    func processReview(card: SpacedRepetitionCard, quality: Int) -> SM2Result {
        let q = max(0, min(5, quality))
        var easeFactor = card.easeFactor
        var interval: Int
        var repetitions: Int

        if q < 3 {
            repetitions = 0
            interval = 1
        } else {
            repetitions = card.repetitions + 1
            switch card.repetitions {
            case 0: interval = 1
            case 1: interval = 6
            default: interval = Int(Double(card.interval) * easeFactor)
            }
            easeFactor = easeFactor + 0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02)
            easeFactor = max(1.3, easeFactor)
        }

        let nextDue = Calendar.current.date(byAdding: .day, value: interval, to: Date()) ?? Date()
        return SM2Result(
            newInterval: interval,
            newEaseFactor: easeFactor,
            newRepetitions: repetitions,
            nextDueDate: nextDue
        )
    }

    func applyResult(_ result: SM2Result, to card: SpacedRepetitionCard) {
        card.interval = result.newInterval
        card.easeFactor = result.newEaseFactor
        card.repetitions = result.newRepetitions
        card.dueDate = result.nextDueDate
        card.lastReviewDate = Date()
        card.reviewCount += 1
    }

    func qualityScore(wasCorrect: Bool, timeSpent: Double, estimatedSeconds: Int) -> Int {
        guard wasCorrect else { return 1 }
        return timeSpent <= Double(estimatedSeconds) ? 5 : 3
    }
}
