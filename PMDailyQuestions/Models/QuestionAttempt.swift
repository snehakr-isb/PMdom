import Foundation
import SwiftData

@Model
final class QuestionAttempt {
    var questionID: String
    var category: String
    var difficulty: String
    var wasCorrect: Bool
    var timeSpentSeconds: Double
    var xpEarned: Int
    var answeredAt: Date

    init(questionID: UUID, category: ContentCategory, difficulty: Difficulty,
         wasCorrect: Bool, timeSpentSeconds: Double, xpEarned: Int) {
        self.questionID = questionID.uuidString
        self.category = category.rawValue
        self.difficulty = difficulty.rawValue
        self.wasCorrect = wasCorrect
        self.timeSpentSeconds = timeSpentSeconds
        self.xpEarned = xpEarned
        self.answeredAt = Date()
    }
}
