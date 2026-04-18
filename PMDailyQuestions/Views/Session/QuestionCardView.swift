import SwiftUI

struct QuestionCardView: View {
    let question: Question
    let isRevealed: Bool
    let onAnswer: (Bool) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                HStack {
                    CategoryTagView(category: question.category)
                    DifficultyBadgeView(difficulty: question.difficulty)
                    Spacer()
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("~\(question.estimatedSeconds)s")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(question.prompt)
                    .font(.title3.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)

                questionContent
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    @ViewBuilder
    private var questionContent: some View {
        switch question.content {
        case .multipleChoice(let options, let correctIndex):
            MultipleChoiceView(options: options, correctIndex: correctIndex, isRevealed: isRevealed, onSelect: onAnswer)
        case .trueFalse(let answer):
            TrueFalseView(correctAnswer: answer, isRevealed: isRevealed, onSelect: onAnswer)
        case .fillInBlank(let template, let blanks):
            FillInBlankView(template: template, blanks: blanks, isRevealed: isRevealed, onSubmit: onAnswer)
        case .scenario(let text, let options, let correctIndex):
            ScenarioView(scenarioText: text, options: options, correctIndex: correctIndex, isRevealed: isRevealed, onSelect: onAnswer)
        case .matching(let pairs, let distractors):
            MatchingView(pairs: pairs, distractors: distractors, isRevealed: isRevealed, onSubmit: onAnswer)
        case .ordering(let steps, let correctOrder):
            OrderingView(steps: steps, correctOrder: correctOrder, isRevealed: isRevealed, onSubmit: onAnswer)
        }
    }
}
