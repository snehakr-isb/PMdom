import SwiftUI

struct CategoryTagView: View {
    let category: ContentCategory

    var body: some View {
        Text(category.displayName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xs)
            .background(AppTheme.CategoryColor.color(for: category).opacity(0.15))
            .foregroundStyle(AppTheme.CategoryColor.color(for: category))
            .clipShape(Capsule())
    }
}

struct DifficultyBadgeView: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.displayName)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var color: Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}
