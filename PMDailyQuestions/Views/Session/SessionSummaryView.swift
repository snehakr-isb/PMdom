import SwiftUI

struct SessionSummaryView: View {
    let sessionXP: Int
    let sessionCorrect: Int
    let totalQuestions: Int
    let streakCount: Int
    let newAchievements: [Achievement]
    let onDone: () -> Void

    private var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(sessionCorrect) / Double(totalQuestions)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                Text("Session Complete!")
                    .font(.largeTitle.weight(.bold))

                // Stats row
                HStack(spacing: AppTheme.Spacing.lg) {
                    StatTile(icon: "bolt.fill", value: "+\(sessionXP)", label: "XP Earned", color: .orange)
                    StatTile(icon: "checkmark.circle.fill", value: "\(sessionCorrect)/\(totalQuestions)", label: "Correct", color: AppTheme.correctGreen)
                    StatTile(icon: "flame.fill", value: "\(streakCount)", label: "Day Streak", color: .orange)
                }

                // Accuracy gauge
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text("Accuracy")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.secondary.opacity(0.15)).frame(height: 12)
                        Capsule().fill(accuracyGradient).frame(width: max(8, CGFloat(accuracy) * 280), height: 12)
                    }
                    .frame(maxWidth: 280)
                    Text("\(Int(accuracy * 100))%")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(accuracy >= 0.7 ? AppTheme.correctGreen : .orange)
                }

                // New achievements
                if !newAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("New Achievements!")
                            .font(.headline)
                        ForEach(newAchievements) { achievement in
                            if let type = achievement.type {
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    Image(systemName: type.iconName)
                                        .foregroundStyle(.yellow)
                                    VStack(alignment: .leading) {
                                        Text(type.title).font(.callout.weight(.semibold))
                                        Text(type.description).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                .padding(AppTheme.Spacing.sm)
                                .background(Color.yellow.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm))
                            }
                        }
                    }
                }

                Button("Done") { onDone() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
            }
            .padding(AppTheme.Spacing.lg)
        }
    }

    private var accuracyGradient: LinearGradient {
        LinearGradient(colors: [.green, accuracy >= 0.7 ? .green : .orange], startPoint: .leading, endPoint: .trailing)
    }
}

private struct StatTile: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon).foregroundStyle(color).font(.title2)
            Text(value).font(.title3.weight(.bold))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.md)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
    }
}
