import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProfileViewModel()
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    profileHeader
                    statsRow
                    Picker("Tab", selection: $selectedTab) {
                        Text("Badges").tag(0)
                        Text("Accuracy").tag(1)
                        Text("History").tag(2)
                    }
                    .pickerStyle(.segmented)

                    switch selectedTab {
                    case 0: badgeGrid
                    case 1: accuracySection
                    case 2: historyList
                    default: EmptyView()
                    }
                }
                .padding(AppTheme.Spacing.md)
            }
            .navigationTitle("Profile")
            .onAppear { viewModel.load(context: modelContext) }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Circle()
                .fill(AppTheme.accent.gradient)
                .frame(width: 72, height: 72)
                .overlay(Text("👤").font(.largeTitle))
            Text(appState.userProgress?.displayName ?? "PM Learner")
                .font(.title3.weight(.bold))
            Text(appState.levelTitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var statsRow: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            StatCard(value: "\(appState.totalXP)", label: "Total XP")
            StatCard(value: "\(appState.streakCount)", label: "Streak")
            StatCard(value: "\(Int((appState.userProgress?.accuracy ?? 0) * 100))%", label: "Accuracy")
        }
    }

    private var badgeGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: AppTheme.Spacing.sm) {
            ForEach(AchievementType.allCases, id: \.self) { type in
                let achievement = viewModel.achievements.first { $0.typeRaw == type.rawValue }
                BadgeTile(type: type, achievement: achievement)
            }
        }
    }

    private var accuracySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Accuracy by Category")
                .font(.headline)
            ForEach(ContentCategory.allCases, id: \.self) { category in
                let acc = viewModel.categoryAccuracy[category] ?? 0
                HStack {
                    CategoryTagView(category: category)
                    Spacer()
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.secondary.opacity(0.15))
                            Capsule()
                                .fill(AppTheme.CategoryColor.color(for: category).gradient)
                                .frame(width: geo.size.width * acc)
                        }
                    }
                    .frame(height: 8)
                    Text("\(Int(acc * 100))%")
                        .font(.caption.weight(.semibold))
                        .frame(width: 36)
                }
            }
        }
    }

    private var historyList: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Recent Activity")
                .font(.headline)
            ForEach(viewModel.recentAttempts.prefix(20)) { attempt in
                HStack {
                    Image(systemName: attempt.wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(attempt.wasCorrect ? AppTheme.correctGreen : AppTheme.wrongRed)
                    Text(ContentCategory(rawValue: attempt.category)?.displayName ?? attempt.category)
                        .font(.callout)
                    Spacer()
                    Text(attempt.answeredAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
    }
}

private struct StatCard: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.title3.weight(.bold)).foregroundStyle(AppTheme.accent)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
    }
}

private struct BadgeTile: View {
    let type: AchievementType
    let achievement: Achievement?
    var isUnlocked: Bool { achievement?.isUnlocked ?? false }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: type.iconName)
                .font(.title)
                .foregroundStyle(isUnlocked ? .yellow : .secondary)
            Text(type.title)
                .font(.caption2.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(isUnlocked ? .primary : .secondary)
        }
        .padding(AppTheme.Spacing.sm)
        .frame(maxWidth: .infinity)
        .background(isUnlocked ? Color.yellow.opacity(0.1) : AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .opacity(isUnlocked ? 1 : 0.5)
    }
}
