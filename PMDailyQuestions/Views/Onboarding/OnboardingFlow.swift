import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    @State private var step = 0

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case 0: WelcomeView { step = 1 }
                case 1: NameInputView(name: $viewModel.displayName) { step = 2 }
                case 2: CategoryPickerView(selected: $viewModel.selectedCategories) { step = 3 }
                case 3: NotificationPermView(viewModel: viewModel) {
                    Task { await completeOnboarding() }
                }
                default: EmptyView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: step)
        }
    }

    private func completeOnboarding() async {
        await viewModel.completeOnboarding(context: modelContext)
    }
}

struct WelcomeView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            VStack(spacing: AppTheme.Spacing.md) {
                Text("📊")
                    .font(.system(size: 80))
                Text("PM Daily")
                    .font(.largeTitle.weight(.black))
                Text("Sharpen your product instincts — one question a day. Like Duolingo, but for Product Managers.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            Spacer()
            VStack(spacing: AppTheme.Spacing.sm) {
                featureRow(icon: "brain.head.profile", text: "Daily PM interview questions")
                featureRow(icon: "cpu", text: "AI & tech fundamentals")
                featureRow(icon: "newspaper", text: "Current tech events")
                featureRow(icon: "flame.fill", text: "Streaks, XP & weekly leagues")
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
            .padding(.horizontal)
            Spacer()
            Button("Get Started") { onNext() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon).foregroundStyle(AppTheme.accent).frame(width: 24)
            Text(text).font(.callout)
            Spacer()
        }
    }
}

struct NameInputView: View {
    @Binding var name: String
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            Text("What should we call you?")
                .font(.title.weight(.bold))
                .multilineTextAlignment(.center)
            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .padding(.horizontal)
            Spacer()
            Button("Continue") { onNext() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
        }
    }
}

struct CategoryPickerView: View {
    @Binding var selected: Set<ContentCategory>
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Text("What do you want to focus on?")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.top, AppTheme.Spacing.xl)
            Text("You'll get a mix each day, but we'll prioritise your interests.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(ContentCategory.allCases, id: \.self) { category in
                    let isSelected = selected.contains(category)
                    Button {
                        if isSelected { selected.remove(category) } else { selected.insert(category) }
                    } label: {
                        HStack {
                            CategoryTagView(category: category)
                            Spacer()
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isSelected ? AppTheme.accent : .secondary)
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(isSelected ? AppTheme.accent.opacity(0.08) : AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            Spacer()
            Button("Continue") { onNext() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(selected.isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
        }
    }
}

struct NotificationPermView: View {
    let viewModel: OnboardingViewModel
    let onComplete: () -> Void
    @State private var requested = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.accent)
            Text("Stay on track")
                .font(.title.weight(.bold))
            Text("Get a daily reminder to keep your streak alive. We'll only send one notification per day.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            VStack(spacing: AppTheme.Spacing.sm) {
                Button("Enable Notifications") {
                    requested = true
                    Task {
                        await viewModel.requestNotificationPermission()
                        onComplete()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                Button("Skip for now") { onComplete() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .disabled(requested)
    }
}
