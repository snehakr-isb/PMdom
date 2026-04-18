import SwiftUI

struct ExplanationView: View {
    let wasCorrect: Bool
    let explanation: String
    let xpEarned: Int
    let onContinue: () -> Void

    @State private var showConfetti = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ZStack {
                ConfettiView(isActive: showConfetti)
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(wasCorrect ? AppTheme.correctGreen : AppTheme.wrongRed)
                    Text(wasCorrect ? "Correct!" : "Not quite")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(wasCorrect ? AppTheme.correctGreen : AppTheme.wrongRed)
                    if xpEarned > 0 {
                        XPBadgeView(xp: xpEarned)
                    }
                }
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("Explanation")
                    .font(.headline)
                Text(explanation)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))

            Button("Continue") { onContinue() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
        }
        .padding(AppTheme.Spacing.md)
        .onAppear {
            if wasCorrect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showConfetti = true
                }
            }
        }
    }
}
