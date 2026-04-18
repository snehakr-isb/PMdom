import Foundation
import SwiftData

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()
    static let appGroupID = "group.com.pmquestions.shared"

    let container: ModelContainer

    private init() {
        let schema = Schema([
            DailyChallenge.self,
            UserProgress.self,
            QuestionAttempt.self,
            Streak.self,
            SpacedRepetitionCard.self,
            Achievement.self
        ])

        let storeURL: URL
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID) {
            storeURL = groupURL.appendingPathComponent("pmdaily.store")
        } else {
            storeURL = URL.documentsDirectory.appendingPathComponent("pmdaily.store")
        }

        let config = ModelConfiguration(schema: schema, url: storeURL)
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    static var preview: PersistenceController = {
        let controller = PersistenceController()
        return controller
    }()
}
