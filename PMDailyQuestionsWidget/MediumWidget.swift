import WidgetKit
import SwiftUI

struct MediumProgressWidget: Widget {
    let kind = "MediumProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PMWidgetProvider()) { entry in
            MediumWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Progress")
        .description("Track today's session progress, XP, and streak.")
        .supportedFamilies([.systemMedium])
    }
}

struct MediumWidgetView: View {
    let entry: PMWidgetEntry

    var body: some View {
        Link(destination: URL(string: "pmquestions://start-session")!) {
            HStack(spacing: 16) {
                progressRing
                VStack(alignment: .leading, spacing: 8) {
                    Text("PM Daily")
                        .font(.headline.weight(.bold))
                    HStack(spacing: 4) {
                        Text("🔥").font(.subheadline)
                        Text("\(entry.streakCount) day streak")
                            .font(.subheadline.weight(.semibold))
                    }
                    Text("\(entry.questionsComplete)/\(entry.questionsTotal) questions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    xpBar
                    if !entry.isSessionComplete {
                        Text("Tap to start")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.15))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    } else {
                        Text("✅ Complete")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                }
            }
            .padding(12)
        }
    }

    private var progressRing: some View {
        let progress = entry.questionsTotal > 0
            ? Double(entry.questionsComplete) / Double(entry.questionsTotal)
            : 0

        return ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            VStack(spacing: 0) {
                Text("\(entry.questionsComplete)")
                    .font(.title2.weight(.black))
                Text("done")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 72, height: 72)
    }

    private var xpBar: some View {
        let fraction = entry.xpToNextLevel > 0
            ? min(Double(entry.totalXP % entry.xpToNextLevel) / Double(entry.xpToNextLevel), 1.0)
            : 1.0
        return VStack(alignment: .leading, spacing: 2) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.2))
                    Capsule()
                        .fill(Color.accentColor.gradient)
                        .frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: 6)
            Text(entry.levelTitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
