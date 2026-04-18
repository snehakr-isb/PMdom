import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingFlow()
            } else {
                mainTabView
            }
        }
        .onAppear {
            appState.loadState(from: modelContext)
        }
        .overlay(alignment: .top) {
            if appState.showAchievementBanner {
                AchievementBannerView(achievements: appState.newlyUnlockedAchievements)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture { appState.showAchievementBanner = false }
                    .padding(.top, 8)
            }
        }
        .animation(.spring(duration: 0.4), value: appState.showAchievementBanner)
    }

    @ViewBuilder
    private var mainTabView: some View {
        @Bindable var appState = appState
        TabView(selection: $appState.activeTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(AppState.Tab.home)

            SkillPathListView()
                .tabItem { Label("Learn", systemImage: "books.vertical.fill") }
                .tag(AppState.Tab.learn)

            LeaderboardView()
                .tabItem { Label("League", systemImage: "trophy.fill") }
                .tag(AppState.Tab.leaderboard)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(AppState.Tab.profile)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(AppState.Tab.settings)
        }
        .tint(AppTheme.accent)
    }
}
