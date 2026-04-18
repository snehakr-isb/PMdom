import WidgetKit
import SwiftUI

struct SmallStreakWidget: Widget {
    let kind = "SmallStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PMWidgetProvider()) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Streak Counter")
        .description("See your daily streak and tap to start your session.")
        .supportedFamilies([.systemSmall])
    }
}

struct SmallWidgetView: View {
    let entry: PMWidgetEntry

    var body: some View {
        Link(destination: URL(string: "pmquestions://start-session")!) {
            VStack(spacing: 6) {
                Spacer()
                Text("🔥")
                    .font(.system(size: 36))
                Text("\(entry.streakCount)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.orange)
                Text("day streak")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                if !entry.isSessionComplete {
                    Text("Tap to practice")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text("Done!").font(.caption2.weight(.semibold)).foregroundStyle(.green)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
