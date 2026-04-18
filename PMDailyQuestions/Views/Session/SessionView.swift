import SwiftUI
import SwiftData

struct SessionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = SessionViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isComplete {
                    SessionSummaryView(
                        sessionXP: viewModel.sessionXP,
                        sessionCorrect: viewModel.sessionCorrect,
                        totalQuestions: viewModel.questions.count,
                        streakCount: appState.streakCount,
                        newAchievements: viewModel.newlyUnlockedAchievements,
                        onDone: { dismiss() }
                    )
                } else if let question = viewModel.currentQuestion {
                    VStack(spacing: 0) {
                        progressHeader
                        if viewModel.showExplanation {
                            ExplanationView(
                                wasCorrect: viewModel.lastAnswerWasCorrect,
                                explanation: question.explanation,
                                xpEarned: viewModel.sessionXP,
                                onContinue: { viewModel.advanceToNext() }
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            QuestionCardView(
                                question: question,
                                isRevealed: viewModel.showExplanation,
                                onAnswer: { wasCorrect in
                                    viewModel.submitAnswer(wasCorrect: wasCorrect)
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .id(question.id)
                        }
                    }
                } else {
                    ProgressView("Preparing your questions...")
                }
            }
            .navigationTitle("Daily Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Exit") { dismiss() }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentIndex)
            .animation(.easeInOut(duration: 0.25), value: viewModel.showExplanation)
        }
        .onAppear {
            viewModel.start(context: modelContext, appState: appState)
        }
    }

    private var progressHeader: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack {
                Text("\(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                XPBadgeView(xp: viewModel.sessionXP, isVisible: viewModel.sessionXP > 0)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.15))
                    Capsule()
                        .fill(AppTheme.accent.gradient)
                        .frame(width: geo.size.width * viewModel.progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
    }
}
