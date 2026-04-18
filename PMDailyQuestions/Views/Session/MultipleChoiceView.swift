import SwiftUI

struct MultipleChoiceView: View {
    let options: [String]
    let correctIndex: Int
    let isRevealed: Bool
    let onSelect: (Bool) -> Void

    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ForEach(options.indices, id: \.self) { i in
                OptionButton(
                    text: options[i],
                    state: buttonState(for: i),
                    isDisabled: isRevealed
                ) {
                    guard !isRevealed, selectedIndex == nil else { return }
                    selectedIndex = i
                    onSelect(i == correctIndex)
                }
            }
        }
        .onChange(of: isRevealed) { _, revealed in
            if !revealed { selectedIndex = nil }
        }
    }

    private func buttonState(for index: Int) -> OptionButtonState {
        guard isRevealed else {
            return selectedIndex == index ? .selected : .idle
        }
        if index == correctIndex { return .correct }
        if index == selectedIndex { return .wrong }
        return .idle
    }
}

enum OptionButtonState { case idle, selected, correct, wrong }

struct OptionButton: View {
    let text: String
    let state: OptionButtonState
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                Spacer()
                if state == .correct {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.correctGreen)
                } else if state == .wrong {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(AppTheme.wrongRed)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(backgroundColor)
            .overlay(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md).stroke(borderColor, lineWidth: 2))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        }
        .disabled(isDisabled)
        .animation(.easeInOut(duration: 0.2), value: state)
    }

    private var backgroundColor: Color {
        switch state {
        case .idle: return AppTheme.cardBackground
        case .selected: return AppTheme.accent.opacity(0.12)
        case .correct: return AppTheme.correctGreen.opacity(0.12)
        case .wrong: return AppTheme.wrongRed.opacity(0.12)
        }
    }

    private var borderColor: Color {
        switch state {
        case .idle: return .clear
        case .selected: return AppTheme.accent
        case .correct: return AppTheme.correctGreen
        case .wrong: return AppTheme.wrongRed
        }
    }
}
