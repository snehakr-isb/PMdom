import Foundation
import SwiftData

@Observable
final class SessionViewModel {
    private(set) var questions: [Question] = []
    private(set) var currentIndex: Int = 0
    private(set) var sessionXP: Int = 0
    private(set) var sessionCorrect: Int = 0
    private(set) var showExplanation: Bool = false
    private(set) var lastAnswerWasCorrect: Bool = false
    private(set) var isComplete: Bool = false
    private(set) var sessionAttempts: [QuestionAttempt] = []
    private(set) var newlyUnlockedAchievements: [Achievement] = []
    private(set) var consecutiveTimeBonuses: Int = 0

    private var questionStartTime: Date = Date()
    private var modelContext: ModelContext?
    private var appState: AppState?

    var currentQuestion: Question? { questions[safe: currentIndex] }
    var progress: Double { questions.isEmpty ? 0 : Double(currentIndex) / Double(questions.count) }
    var isLastQuestion: Bool { currentIndex >= questions.count - 1 }

    func start(context: ModelContext, appState: AppState) {
        self.modelContext = context
        self.appState = appState

        let allQuestions = QuestionRepository.shared.allQuestions()
        let dueCards = ProgressRepository.shared.dueCards(context: context)
        let completedIDs = ProgressRepository.shared.completedQuestionIDs(context: context, withinDays: 7)
        let progress = appState.userProgress ?? UserProgress()

        questions = DailyMixService.shared.buildDailyMix(
            allQuestions: allQuestions,
            dueCards: dueCards,
            recentlyCompletedIDs: completedIDs,
            progress: progress
        )
        currentIndex = 0
        sessionXP = 0
        sessionCorrect = 0
        showExplanation = false
        isComplete = false
        sessionAttempts = []
        consecutiveTimeBonuses = 0
        questionStartTime = Date()
    }

    func submitAnswer(wasCorrect: Bool) {
        guard let question = currentQuestion,
              let context = modelContext,
              let appState = appState,
              let streak = appState.streak else { return }

        let timeSpent = Date().timeIntervalSince(questionStartTime)
        let xp = XPService.shared.calculate(
            questionType: question.type,
            difficulty: question.difficulty,
            wasCorrect: wasCorrect,
            timeSpent: timeSpent,
            estimatedSeconds: question.estimatedSeconds,
            streakCount: streak.currentCount
        )

        let earnedTimeBonus = wasCorrect && timeSpent <= Double(question.estimatedSeconds)
        consecutiveTimeBonuses = earnedTimeBonus ? consecutiveTimeBonuses + 1 : 0

        ProgressRepository.shared.saveAttempt(
            context: context,
            questionID: question.id,
            category: question.category,
            difficulty: question.difficulty,
            wasCorrect: wasCorrect,
            timeSpent: timeSpent,
            xpEarned: xp
        )
        ProgressRepository.shared.updateSRCard(
            context: context,
            questionID: question.id,
            wasCorrect: wasCorrect,
            timeSpent: timeSpent,
            estimatedSeconds: question.estimatedSeconds
        )

        appState.userProgress?.addXP(xp)
        appState.userProgress?.recordAttempt(wasCorrect: wasCorrect)
        appState.todaysChallenge?.markCompleted(questionID: question.id, xpEarned: xp)

        sessionXP += xp
        if wasCorrect { sessionCorrect += 1 }
        lastAnswerWasCorrect = wasCorrect
        showExplanation = true
    }

    func advanceToNext() {
        showExplanation = false
        questionStartTime = Date()
        if isLastQuestion {
            completeSession()
        } else {
            currentIndex += 1
        }
    }

    private func completeSession() {
        guard let context = modelContext, let appState = appState else { return }

        if let streak = appState.streak {
            StreakService.shared.recordSessionCompletion(streak: streak)
            NotificationService.shared.cancelStreakRiskNotification()
        }

        if let progress = appState.userProgress, let streak = appState.streak {
            let recentAttempts = ProgressRepository.shared.recentAttempts(context: context)
            let unlocked = AchievementEngine.shared.evaluateAfterSession(
                context: context,
                streak: streak,
                progress: progress,
                sessionAttempts: sessionAttempts,
                allAttempts: recentAttempts,
                consecutiveTimeBonuses: consecutiveTimeBonuses
            )
            newlyUnlockedAchievements = unlocked
            if !unlocked.isEmpty {
                appState.triggerAchievementBanner(for: unlocked)
            }
        }

        try? context.save()
        isComplete = true
    }
}
