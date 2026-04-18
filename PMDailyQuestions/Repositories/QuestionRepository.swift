import Foundation

final class QuestionRepository {
    static let shared = QuestionRepository()
    private init() {}

    private let lastSyncKey = "lastQuestionSyncDate"

    func allQuestions() -> [Question] {
        BundleQuestionLoader.shared.load()
    }

    func question(by id: UUID) -> Question? {
        allQuestions().first { $0.id == id }
    }

    func questions(for category: ContentCategory, difficulty: Difficulty) -> [Question] {
        allQuestions().filter { $0.category == category && $0.difficulty == difficulty }
    }

    func syncIfNeeded() async {
        let lastSync = UserDefaults.standard.object(forKey: lastSyncKey) as? Date ?? .distantPast
        guard Date().timeIntervalSince(lastSync) > 3600 else { return } // sync at most hourly

        do {
            let newQuestions = try await NetworkService.shared.fetchQuestions(since: lastSync)
            guard !newQuestions.isEmpty else { return }

            let existing = BundleQuestionLoader.shared.load()
            let existingIDs = Set(existing.map(\.id))
            let merged = existing + newQuestions.filter { !existingIDs.contains($0.id) }
            BundleQuestionLoader.shared.saveToAppGroupCache(merged)
            UserDefaults.standard.set(Date(), forKey: lastSyncKey)
        } catch {
            // Silently fall back to local cache
        }
    }
}
