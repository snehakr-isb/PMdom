import SwiftUI

struct OrderingView: View {
    let steps: [String]
    let correctOrder: [Int]
    let isRevealed: Bool
    let onSubmit: (Bool) -> Void

    @State private var userOrder: [Int] = []

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Arrange these steps in the correct order:")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if !isRevealed {
                ForEach(userOrder.indices, id: \.self) { position in
                    let stepIndex = userOrder[position]
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text("\(position + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(AppTheme.accent)
                            .clipShape(Circle())
                        Text(steps[safe: stepIndex] ?? "")
                            .font(.callout)
                        Spacer()
                        VStack(spacing: 4) {
                            if position > 0 {
                                Button { moveStep(from: position, to: position - 1) } label: {
                                    Image(systemName: "chevron.up").font(.caption)
                                }
                            }
                            if position < userOrder.count - 1 {
                                Button { moveStep(from: position, to: position + 1) } label: {
                                    Image(systemName: "chevron.down").font(.caption)
                                }
                            }
                        }
                        .foregroundStyle(AppTheme.accent)
                    }
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm))
                }

                Button("Submit Order") { submitOrder() }
                    .buttonStyle(.borderedProminent)
            } else {
                ForEach(correctOrder.indices, id: \.self) { position in
                    let stepIndex = correctOrder[position]
                    let userStepIndex = userOrder[safe: position]
                    let isCorrect = userStepIndex == stepIndex

                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(isCorrect ? AppTheme.correctGreen : AppTheme.wrongRed)
                        Text(steps[safe: stepIndex] ?? "")
                            .font(.callout)
                    }
                    .padding(AppTheme.Spacing.sm)
                    .background(isCorrect ? AppTheme.correctGreen.opacity(0.1) : AppTheme.wrongRed.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm))
                }
            }
        }
        .onAppear {
            userOrder = Array(steps.indices).shuffled()
        }
        .onChange(of: isRevealed) { _, revealed in
            if !revealed { userOrder = Array(steps.indices).shuffled() }
        }
    }

    private func moveStep(from: Int, to: Int) {
        userOrder.swapAt(from, to)
    }

    private func submitOrder() {
        let correct = userOrder == correctOrder
        onSubmit(correct)
    }
}
