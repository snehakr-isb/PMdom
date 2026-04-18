import Foundation

final class NetworkService {
    static let shared = NetworkService()
    private init() {}

    private let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
    private let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String ?? ""

    func fetchQuestions(since date: Date) async throws -> [Question] {
        guard !supabaseURL.isEmpty else { return [] }

        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        let urlString = "\(supabaseURL)/rest/v1/questions?published_date=gte.\(dateString)&order=published_date.asc"

        guard let url = URL(string: urlString) else { return [] }
        var request = URLRequest(url: url)
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let raw = try decoder.decode([QuestionDTO].self, from: data)
        return raw.compactMap(\.question)
    }

    enum NetworkError: Error {
        case invalidResponse
        case decodingFailed
    }
}

// Supabase row → domain model bridge
private struct QuestionDTO: Decodable {
    let id: String
    let type: String
    let category: String
    let difficulty: String
    let prompt: String
    let content: QuestionContent
    let explanation: String
    let tags: [String]?
    let xp_value: Int
    let estimated_seconds: Int
    let published_date: String

    var question: Question? {
        guard let uuid = UUID(uuidString: id),
              let type = QuestionType(rawValue: type),
              let category = ContentCategory(rawValue: category),
              let difficulty = Difficulty(rawValue: difficulty) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: published_date) ?? Date()
        return Question(
            id: uuid, type: type, category: category, difficulty: difficulty,
            prompt: prompt, content: content, explanation: explanation,
            tags: tags ?? [], skillPathID: nil, baseXP: xp_value,
            estimatedSeconds: estimated_seconds, publishedDate: date, version: 1
        )
    }
}
