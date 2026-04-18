import SwiftUI

struct TrueFalseView: View {
    let correctAnswer: Bool
    let isRevealed: Bool
    let onSelect: (Bool) -> Void

    @State private var selected: Bool? = nil

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            TFButton(label: "True", isCorrect: correctAnswer, isSelected: selected == true, isRevealed: isRevealed) {
                guard !isRevealed, selected == nil else { return }
                selected = true
                onSelect(true == correctAnswer)
            }
            TFButton(label: "False", isCorrect: !correctAnswer, isSelected: selected == false, isRevealed: isRevealed) {
                guard !isRevealed, selected == nil else { return }
                selected = false
                onSelect(false == correctAnswer)
            }
        }
        .onChange(of: isRevealed) { _, revealed in if !revealed { selected = nil } }
    }
}

private struct TFButton: View {
    let label: String
    let isCorrect: Bool
    let isSelected: Bool
    let isRevealed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundStyle(iconColor)
                Text(label)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(iconColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.xl)
            .background(bgColor)
            .overlay(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg).stroke(borderColor, lineWidth: 2))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
        }
        .disabled(isRevealed)
        .animation(.easeInOut(duration: 0.2), value: isRevealed)
    }

    private var icon: String {
        if !isRevealed { return isSelected ? "hand.point.right.fill" : "circle" }
        return isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
    }
    private var iconColor: Color {
        if !isRevealed { return isSelected ? AppTheme.accent : .secondary }
        return isCorrect ? AppTheme.correctGreen : AppTheme.wrongRed
    }
    private var bgColor: Color {
        if !isRevealed { return isSelected ? AppTheme.accent.opacity(0.1) : AppTheme.cardBackground }
        return isCorrect ? AppTheme.correctGreen.opacity(0.1) : AppTheme.wrongRed.opacity(0.1)
    }
    private var borderColor: Color {
        if !isRevealed { return isSelected ? AppTheme.accent : .clear }
        return isCorrect ? AppTheme.correctGreen : AppTheme.wrongRed
    }
}
