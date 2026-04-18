import Foundation
import SwiftData

@Model
final class SpacedRepetitionCard {
    var questionID: String
    var easeFactor: Double
    var interval: Int
    var repetitions: Int
    var dueDate: Date
    var lastReviewDate: Date?
    var reviewCount: Int

    init(questionID: UUID) {
        self.questionID = questionID.uuidString
        self.easeFactor = 2.5
        self.interval = 1
        self.repetitions = 0
        self.dueDate = Date()
        self.lastReviewDate = nil
        self.reviewCount = 0
    }

    var isDue: Bool {
        dueDate <= Date()
    }
}
