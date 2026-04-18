import WidgetKit
import SwiftUI

struct LargeLeaderWidget: Widget {
    let kind = "LargeLeaderWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PMWidgetProvider()) { entry in
            LargeWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Leaderboard + Progress")
        .description("See your weekly rank alongside today's challenge progress.")
        .supportedFamilies([.systemLarge])
    }
}

struct LargeWidgetView: View {
    let entry: PMWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            Divider()
            leaderboardSection
            Divider()
            sessionSection
        }
        .padding(14)
    }

    private var headerRow: some View {
        HStack {
            Text("PM Daily")
                .font(.headline.weight(.bold))
            Spacer()
            HStack(spacing: 4) {
                Text("🔥")
                Text("\(entry.streakCount)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.orange)
                Text("days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Weekly League")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(entry.leaderboardTop3, id: \.rank) { row in
                Link(destination: URL(string: "pmquestions://leaderboard")!) {
                    HStack(spacing: 8) {
                        Text(row.rank == 1 ? "🥇" : row.rank == 2 ? "🥈" : "🥉")
                            .font(.subheadline)
                        Text(row.displayName)
                            .font(.callout.weight(row.isCurrentUser ? .bold : .regular))
                            .foregroundStyle(row.isCurrentUser ? .accentColor : .primary)
                        Spacer()
                        Text("\(row.weeklyXP) XP")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var sessionSection: some View {
        Link(destination: URL(string: "pmquestions://start-session")!) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Today's Session")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(entry.questionsComplete)/\(entry.questionsTotal)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.accentColor)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.secondary.opacity(0.2))
                        let progress = entry.questionsTotal > 0
                            ? Double(entry.questionsComplete) / Double(entry.questionsTotal)
                            : 0
                        Capsule()
                            .fill(Color.accentColor.gradient)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 8)
                Text(entry.isSessionComplete ? "✅ Completed! Great work." : "Tap to start today's \(entry.todayCategoryName) challenge")
                    .font(.caption)
                    .foregroundStyle(entry.isSessionComplete ? .green : .secondary)
            }
        }
    }
}
