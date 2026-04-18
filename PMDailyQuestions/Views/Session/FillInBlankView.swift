import SwiftUI

struct FillInBlankView: View {
    let template: String
    let blanks: [BlankAnswer]
    let isRevealed: Bool
    let onSubmit: (Bool) -> Void

    @State private var answers: [String] = []
    @FocusState private var focusedBlank: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Fill in the blanks:")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            blankFields

            if !isRevealed {
                Button("Check Answer") {
                    submitAnswers()
                }
                .buttonStyle(.borderedProminent)
                .disabled(answers.contains(where: \.isEmpty))
            }
        }
        .onAppear {
            answers = Array(repeating: "", count: blanks.count)
        }
        .onChange(of: isRevealed) { _, revealed in
            if !revealed { answers = Array(repeating: "", count: blanks.count) }
        }
    }

    @ViewBuilder
    private var blankFields: some View {
        ForEach(blanks.indices, id: \.self) { i in
            HStack {
                Text("Blank \(i + 1):")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(width: 70, alignment: .leading)

                TextField("Type answer...", text: Binding(
                    get: { answers[safe: i] ?? "" },
                    set: { if i < answers.count { answers[i] = $0 } }
                ))
                .textFieldStyle(.roundedBorder)
                .focused($focusedBlank, equals: i)
                .disabled(isRevealed)
                .overlay(alignment: .trailing) {
                    if isRevealed {
                        let correct = isCorrect(index: i)
                        Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(correct ? AppTheme.correctGreen : AppTheme.wrongRed)
                            .padding(.trailing, 8)
                    }
                }

                if isRevealed {
                    Text(blanks[i].answer)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(AppTheme.correctGreen)
                }
            }
        }
    }

    private func submitAnswers() {
        let allCorrect = blanks.indices.allSatisfy { isCorrect(index: $0) }
        onSubmit(allCorrect)
    }

    private func isCorrect(index: Int) -> Bool {
        guard index < blanks.count, index < answers.count else { return false }
        let blank = blanks[index]
        let userAnswer = blank.caseSensitive ? answers[index] : answers[index].lowercased()
        let correctAnswer = blank.caseSensitive ? blank.answer : blank.answer.lowercased()
        let alts = blank.alternateAnswers.map { blank.caseSensitive ? $0 : $0.lowercased() }
        return userAnswer == correctAnswer || alts.contains(userAnswer)
    }
}
