import Foundation
import SwiftData

@Observable
final class HomeViewModel {
    private(set) var isLoadingSync: Bool = false

    func syncQuestions() async {
        isLoadingSync = true
        await QuestionRepository.shared.syncIfNeeded()
        isLoadingSync = false
    }

    func onAppear(appState: AppState, context: ModelContext) {
        evaluateStreak(appState: appState, context: context)
        createTodaysChallengeIfNeeded(appState: appState, context: context)
        Task { await syncQuestions() }
    }

    private func evaluateStreak(appState: AppState, context: ModelContext) {
        guard let streak = appState.streak else { return }
        let action = StreakService.shared.evaluateOnOpen(streak: streak)
        switch action {
        case .savedByFreeze, .reset:
            try? context.save()
        default:
            break
        }
    }

    private func createTodaysChallengeIfNeeded(appState: AppState, context: ModelContext) {
        guard appState.todaysChallenge == nil else { return }

        let allQuestions = QuestionRepository.shared.allQuestions()
        let dueCards = ProgressRepository.shared.dueCards(context: context)
        let completedIDs = ProgressRepository.shared.completedQuestionIDs(context: context, withinDays: 7)
        let progress = appState.userProgress ?? UserProgress()

        let todaysQuestions = DailyMixService.shared.buildDailyMix(
            allQuestions: allQuestions,
            dueCards: dueCards,
            recentlyCompletedIDs: completedIDs,
            progress: progress
        )

        let challenge = DailyChallenge(date: Date(), questionIDs: todaysQuestions.map(\.id))
        context.insert(challenge)
        appState.todaysChallenge = challenge
        try? context.save()
    }
}
