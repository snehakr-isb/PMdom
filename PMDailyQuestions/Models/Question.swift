import Foundation

enum QuestionType: String, Codable, CaseIterable {
    case multipleChoice
    case fillInBlank
    case scenario
    case matching
    case trueFalse
    case ordering
}

enum ContentCategory: String, Codable, CaseIterable {
    case interviewPrep
    case pmFrameworks
    case aiTechFundamentals
    case currentEvents

    var displayName: String {
        switch self {
        case .interviewPrep: return "Interview Prep"
        case .pmFrameworks: return "PM Frameworks"
        case .aiTechFundamentals: return "AI & Tech"
        case .currentEvents: return "Current Events"
        }
    }

    var dailyWeight: Double {
        switch self {
        case .interviewPrep: return 0.40
        case .pmFrameworks: return 0.30
        case .currentEvents: return 0.20
        case .aiTechFundamentals: return 0.10
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced

    var xpMultiplier: Double {
        switch self {
        case .beginner: return 1.0
        case .intermediate: return 1.25
        case .advanced: return 1.5
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

struct Question: Identifiable, Codable, Hashable {
    let id: UUID
    let type: QuestionType
    let category: ContentCategory
    let difficulty: Difficulty
    let prompt: String
    let content: QuestionContent
    let explanation: String
    let tags: [String]
    let skillPathID: UUID?
    let baseXP: Int
    let estimatedSeconds: Int
    let publishedDate: Date
    let version: Int

    var xpValue: Int {
        Int(Double(baseXP) * difficulty.xpMultiplier)
    }

    static func == (lhs: Question, rhs: Question) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum QuestionContent: Codable, Hashable {
    case multipleChoice(options: [String], correctIndex: Int)
    case fillInBlank(template: String, blanks: [BlankAnswer])
    case scenario(scenarioText: String, options: [String], correctIndex: Int)
    case matching(pairs: [MatchPair], distractors: [String])
    case trueFalse(answer: Bool)
    case ordering(steps: [String], correctOrder: [Int])

    private enum CodingKeys: String, CodingKey {
        case type, options, correctIndex, template, blanks
        case scenarioText, pairs, distractors, answer, steps, correctOrder
    }

    private enum ContentType: String, Codable {
        case multipleChoice, fillInBlank, scenario, matching, trueFalse, ordering
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .multipleChoice(let options, let correctIndex):
            try container.encode(ContentType.multipleChoice, forKey: .type)
            try container.encode(options, forKey: .options)
            try container.encode(correctIndex, forKey: .correctIndex)
        case .fillInBlank(let template, let blanks):
            try container.encode(ContentType.fillInBlank, forKey: .type)
            try container.encode(template, forKey: .template)
            try container.encode(blanks, forKey: .blanks)
        case .scenario(let scenarioText, let options, let correctIndex):
            try container.encode(ContentType.scenario, forKey: .type)
            try container.encode(scenarioText, forKey: .scenarioText)
            try container.encode(options, forKey: .options)
            try container.encode(correctIndex, forKey: .correctIndex)
        case .matching(let pairs, let distractors):
            try container.encode(ContentType.matching, forKey: .type)
            try container.encode(pairs, forKey: .pairs)
            try container.encode(distractors, forKey: .distractors)
        case .trueFalse(let answer):
            try container.encode(ContentType.trueFalse, forKey: .type)
            try container.encode(answer, forKey: .answer)
        case .ordering(let steps, let correctOrder):
            try container.encode(ContentType.ordering, forKey: .type)
            try container.encode(steps, forKey: .steps)
            try container.encode(correctOrder, forKey: .correctOrder)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)
        switch type {
        case .multipleChoice:
            let options = try container.decode([String].self, forKey: .options)
            let correctIndex = try container.decode(Int.self, forKey: .correctIndex)
            self = .multipleChoice(options: options, correctIndex: correctIndex)
        case .fillInBlank:
            let template = try container.decode(String.self, forKey: .template)
            let blanks = try container.decode([BlankAnswer].self, forKey: .blanks)
            self = .fillInBlank(template: template, blanks: blanks)
        case .scenario:
            let scenarioText = try container.decode(String.self, forKey: .scenarioText)
            let options = try container.decode([String].self, forKey: .options)
            let correctIndex = try container.decode(Int.self, forKey: .correctIndex)
            self = .scenario(scenarioText: scenarioText, options: options, correctIndex: correctIndex)
        case .matching:
            let pairs = try container.decode([MatchPair].self, forKey: .pairs)
            let distractors = try container.decode([String].self, forKey: .distractors)
            self = .matching(pairs: pairs, distractors: distractors)
        case .trueFalse:
            let answer = try container.decode(Bool.self, forKey: .answer)
            self = .trueFalse(answer: answer)
        case .ordering:
            let steps = try container.decode([String].self, forKey: .steps)
            let correctOrder = try container.decode([Int].self, forKey: .correctOrder)
            self = .ordering(steps: steps, correctOrder: correctOrder)
        }
    }
}

struct BlankAnswer: Codable, Hashable {
    let position: Int
    let answer: String
    let alternateAnswers: [String]
    let caseSensitive: Bool
}

struct MatchPair: Codable, Identifiable, Hashable {
    let id: UUID
    let left: String
    let right: String
}
