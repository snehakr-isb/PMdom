import SwiftUI

struct ScenarioView: View {
    let scenarioText: String
    let options: [String]
    let correctIndex: Int
    let isRevealed: Bool
    let onSelect: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            ScrollView {
                Text(scenarioText)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.accent.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
            }
            .frame(maxHeight: 180)

            Text("What's the best approach?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            MultipleChoiceView(
                options: options,
                correctIndex: correctIndex,
                isRevealed: isRevealed,
                onSelect: onSelect
            )
        }
    }
}
