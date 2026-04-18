import SwiftUI

struct LeaderboardView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = LeaderboardViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tierPicker
                if let userEntry = viewModel.currentUserEntry {
                    userRankBanner(entry: userEntry)
                }
                List(viewModel.filteredEntries) { entry in
                    LeaderboardRowView(entry: entry)
                        .listRowBackground(entry.isCurrentUser ? AppTheme.accent.opacity(0.08) : nil)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Weekly League")
            .onAppear {
                viewModel.load(appState: appState)
            }
        }
    }

    private var tierPicker: some View {
        Picker("Tier", selection: $viewModel.selectedTier) {
            ForEach(LeaderboardEntry.Tier.allCases, id: \.self) { tier in
                Text(tier.rawValue).tag(tier)
            }
        }
        .pickerStyle(.segmented)
        .padding(AppTheme.Spacing.md)
    }

    private func userRankBanner(entry: LeaderboardEntry) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "person.fill")
                .foregroundStyle(AppTheme.accent)
            Text("Your rank: #\(entry.rank)")
                .font(.callout.weight(.semibold))
            Spacer()
            Text("\(entry.weeklyXP) XP this week")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(AppTheme.Spacing.sm)
        .padding(.horizontal, AppTheme.Spacing.sm)
        .background(AppTheme.accent.opacity(0.08))
    }
}

struct LeaderboardRowView: View {
    let entry: LeaderboardEntry

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Text(rankLabel)
                .font(.headline.weight(.bold))
                .foregroundStyle(rankColor)
                .frame(width: 32)

            Circle()
                .fill(AppTheme.accent.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(Text(String(entry.displayName.prefix(1))).font(.callout.weight(.bold)).foregroundStyle(AppTheme.accent))

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(entry.isCurrentUser ? AppTheme.accent : .primary)
                Text(entry.tier.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.weeklyXP)")
                    .font(.callout.weight(.bold))
                Text("XP")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }

    private var rankLabel: String {
        switch entry.rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "#\(entry.rank)"
        }
    }

    private var rankColor: Color {
        switch entry.rank {
        case 1: return .yellow
        case 2: return Color(.systemGray)
        case 3: return .orange
        default: return .secondary
        }
    }
}
