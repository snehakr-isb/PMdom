import SwiftUI

struct MatchingView: View {
    let pairs: [MatchPair]
    let distractors: [String]
    let isRevealed: Bool
    let onSubmit: (Bool) -> Void

    @State private var selectedLeft: UUID? = nil
    @State private var matched: [UUID: String] = [:]
    private var rightOptions: [String] {
        (pairs.map(\.right) + distractors).shuffled()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Match each item on the left with the correct description:")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(pairs) { pair in
                        leftCard(pair: pair)
                    }
                }
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(rightOptions, id: \.self) { option in
                        rightCard(option: option)
                    }
                }
            }

            if !isRevealed && matched.count == pairs.count {
                Button("Check Matches") {
                    let correct = pairs.allSatisfy { matched[$0.id] == $0.right }
                    onSubmit(correct)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    @ViewBuilder
    private func leftCard(pair: MatchPair) -> some View {
        let isSelected = selectedLeft == pair.id
        let matchedRight = matched[pair.id]
        let isCorrect = isRevealed && matchedRight == pair.right

        Button {
            if !isRevealed { selectedLeft = isSelected ? nil : pair.id }
        } label: {
            Text(pair.left)
                .font(.callout.weight(.semibold))
                .padding(AppTheme.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isSelected ? AppTheme.accent.opacity(0.15) :
                            isRevealed ? (isCorrect ? AppTheme.correctGreen.opacity(0.12) : AppTheme.wrongRed.opacity(0.12)) :
                            AppTheme.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                    .stroke(isSelected ? AppTheme.accent : .clear, lineWidth: 2))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm))
        }
        .disabled(isRevealed)
    }

    @ViewBuilder
    private func rightCard(option: String) -> some View {
        let isAlreadyMatched = matched.values.contains(option)
        let isCorrectOption = isRevealed && pairs.contains(where: { $0.right == option && matched[$0.id] == option })

        Button {
            guard !isRevealed, let leftID = selectedLeft, !isAlreadyMatched else { return }
            matched[leftID] = option
            selectedLeft = nil
        } label: {
            Text(option)
                .font(.callout)
                .padding(AppTheme.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isAlreadyMatched ? Color.secondary.opacity(0.1) :
                            isRevealed ? (isCorrectOption ? AppTheme.correctGreen.opacity(0.12) : AppTheme.cardBackground) :
                            AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm))
                .opacity(isAlreadyMatched && !isRevealed ? 0.4 : 1)
        }
        .disabled(isRevealed || (isAlreadyMatched && !isRevealed))
    }
}
