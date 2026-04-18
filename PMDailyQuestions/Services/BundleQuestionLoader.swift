import Foundation

final class BundleQuestionLoader {
    static let shared = BundleQuestionLoader()
    private init() {}

    private var cachedQuestions: [Question]?

    func load() -> [Question] {
        if let cached = cachedQuestions { return cached }

        // Check App Group cache first (fresher Supabase-synced questions)
        if let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: SharedConstants.appGroupID
        ) {
            let cacheURL = appGroupURL.appendingPathComponent("questions_cache.json")
            if let data = try? Data(contentsOf: cacheURL),
               let questions = decode(data) {
                cachedQuestions = questions
                return questions
            }
        }

        // Fall back to bundle seed
        guard let url = Bundle.main.url(forResource: "questions_seed", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questions = decode(data) else {
            return []
        }
        cachedQuestions = questions
        return questions
    }

    func invalidateCache() {
        cachedQuestions = nil
    }

    func saveToAppGroupCache(_ questions: [Question]) {
        guard let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: SharedConstants.appGroupID
        ) else { return }
        let cacheURL = appGroupURL.appendingPathComponent("questions_cache.json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(questions) else { return }
        try? data.write(to: cacheURL)
        invalidateCache()
    }

    private func decode(_ data: Data) -> [Question]? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        struct Wrapper: Decodable { let questions: [Question] }
        if let wrapper = try? decoder.decode(Wrapper.self, from: data) {
            return wrapper.questions
        }
        return try? decoder.decode([Question].self, from: data)
    }
}
