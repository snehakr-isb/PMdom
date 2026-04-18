import SwiftUI

struct XPBadgeView: View {
    let xp: Int
    var isVisible: Bool = true

    var body: some View {
        if isVisible && xp > 0 {
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .font(.caption.weight(.bold))
                Text("+\(xp) XP")
                    .font(.callout.weight(.bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.gradient)
            .clipShape(Capsule())
            .shadow(color: .orange.opacity(0.4), radius: 6, y: 3)
        }
    }
}

struct AchievementBannerView: View {
    let achievements: [Achievement]
    @State private var currentIndex = 0

    var body: some View {
        if let achievement = achievements[safe: currentIndex], let type = achievement.type {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: type.iconName)
                    .font(.title2)
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievement Unlocked!")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                    Text(type.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding(AppTheme.Spacing.md)
            .background(Color.indigo.gradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
            .padding(.horizontal, AppTheme.Spacing.md)
            .shadow(radius: 8, y: 4)
        }
    }
}
