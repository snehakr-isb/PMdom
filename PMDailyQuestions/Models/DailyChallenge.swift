import Foundation
import SwiftData

@Model
final class DailyChallenge {
    var date: Date
    var questionIDs: [String]
    var completedIDs: [String]
    var totalXPEarned: Int
    var sessionDurationSeconds: Int
    var isComplete: Bool
    var generatedAt: Date

    init(date: Date, questionIDs: [UUID]) {
        self.date = Calendar.current.startOfDay(for: date)
        self.questionIDs = questionIDs.map(\.uuidString)
        self.completedIDs = []
        self.totalXPEarned = 0
        self.sessionDurationSeconds = 0
        self.isComplete = false
        self.generatedAt = Date()
    }

    var completedCount: Int { completedIDs.count }
    var totalCount: Int { questionIDs.count }
    var progressFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    func markCompleted(questionID: UUID, xpEarned: Int) {
        let idString = questionID.uuidString
        guard !completedIDs.contains(idString) else { return }
        completedIDs.append(idString)
        totalXPEarned += xpEarned
        if completedIDs.count >= questionIDs.count {
            isComplete = true
        }
    }
}
