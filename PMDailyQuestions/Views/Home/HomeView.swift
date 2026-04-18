import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @State private var showSession = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    greetingHeader
                    streakCard
                    progressCard
                    startButton
                    categoryBreakdown
                }
                .padding(AppTheme.Spacing.md)
            }
            .navigationTitle("PM Daily")
            .onAppear {
                viewModel.onAppear(appState: appState, context: modelContext)
            }
        }
        .fullScreenCover(isPresented: $showSession) {
            SessionView()
        }
    }

    private var greetingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title2.weight(.bold))
                Text(appState.levelTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text("📊")
                    .font(.title2)
            }
        }
    }

    private var streakCard: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            VStack(spacing: AppTheme.Spacing.xs) {
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 32))
                    Text("\(appState.streakCount)")
                        .font(.system(size: 36, weight: .black))
                }
                Text("Day Streak")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 50)

            VStack(spacing: AppTheme.Spacing.xs) {
                Text("\(appState.totalXP)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.accent)
                Text("Total XP")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 50)

            VStack(spacing: AppTheme.Spacing.xs) {
                Text(appState.isActiveToday ? "✅" : "⏳")
                    .font(.system(size: 28))
                Text(appState.isActiveToday ? "Done!" : "Pending")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                Spacer()
                Text("\(appState.todayQuestionsComplete)/\(appState.todayQuestionsTotal)")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.15))
                    Capsule()
                        .fill(AppTheme.accent.gradient)
                        .frame(width: geo.size.width * appState.todayProgressFraction)
                }
            }
            .frame(height: 10)
            .animation(.spring(duration: 0.5), value: appState.todayProgressFraction)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
    }

    private var startButton: some View {
        Button {
            showSession = true
        } label: {
            HStack {
                Image(systemName: appState.isActiveToday ? "arrow.counterclockwise" : "play.fill")
                Text(appState.isActiveToday ? "Practice More" : "Start Today's Session")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.accent.gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
        }
        .disabled(viewModel.isLoadingSync)
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Today's Mix")
                .font(.headline)
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(ContentCategory.allCases, id: \.self) { category in
                    VStack(spacing: 4) {
                        Text("\(Int(category.dailyWeight * 100))%")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.CategoryColor.color(for: category))
                        Text(category.displayName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.CategoryColor.color(for: category).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm))
                }
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning 👋"
        case 12..<17: return "Good afternoon 👋"
        default: return "Good evening 👋"
        }
    }
}
