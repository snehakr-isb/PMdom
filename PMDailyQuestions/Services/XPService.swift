import Foundation

final class XPService {
    static let shared = XPService()
    private init() {}

    private let baseXP: [QuestionType: Int] = [
        .multipleChoice: 10,
        .trueFalse: 10,
        .fillInBlank: 15,
        .matching: 15,
        .scenario: 20,
        .ordering: 20
    ]

    static let timeBonusXP = 5

    func calculate(
        questionType: QuestionType,
        difficulty: Difficulty,
        wasCorrect: Bool,
        timeSpent: Double,
        estimatedSeconds: Int,
        streakCount: Int
    ) -> Int {
        guard wasCorrect else { return 0 }

        let base = baseXP[questionType] ?? 10
        let withDifficulty = Int(Double(base) * difficulty.xpMultiplier)
        let timeBonus = timeSpent <= Double(estimatedSeconds) ? Self.timeBonusXP : 0
        let subtotal = withDifficulty + timeBonus
        let streakMultiplier = Self.streakMultiplier(for: streakCount)
        return Int(Double(subtotal) * streakMultiplier)
    }

    static func streakMultiplier(for streakCount: Int) -> Double {
        switch streakCount {
        case 100...: return 1.5
        case 30...: return 1.2
        case 7...: return 1.1
        default: return 1.0
        }
    }
}
