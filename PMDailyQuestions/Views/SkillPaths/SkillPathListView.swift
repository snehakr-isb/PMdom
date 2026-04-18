import SwiftUI

struct SkillPathListView: View {
    private let paths = SkillPath.builtIn

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: AppTheme.Spacing.md) {
                    ForEach(paths) { path in
                        NavigationLink(destination: SkillPathDetailView(path: path)) {
                            SkillPathCard(path: path)
                        }
                    }
                }
                .padding(AppTheme.Spacing.md)
            }
            .navigationTitle("Skill Paths")
        }
    }
}

private struct SkillPathCard: View {
    let path: SkillPath

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(path.emoji)
                .font(.system(size: 36))
            Text(path.title)
                .font(.callout.weight(.bold))
                .multilineTextAlignment(.leading)
            Text("\(path.totalDays) days")
                .font(.caption)
                .foregroundStyle(.secondary)
            CategoryTagView(category: path.category)
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
    }
}

struct SkillPathDetailView: View {
    let path: SkillPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text(path.description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))

                Text("Curriculum")
                    .font(.headline)
                    .padding(.top, AppTheme.Spacing.sm)

                ForEach(path.nodes.indices, id: \.self) { i in
                    NodeRow(index: i, node: path.nodes[i])
                }
            }
            .padding(AppTheme.Spacing.md)
        }
        .navigationTitle(path.title)
    }
}

private struct NodeRow: View {
    let index: Int
    let node: SkillPathNode

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.15))
                    .frame(width: 36, height: 36)
                Text("\(index + 1)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.accent)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(node.title).font(.callout.weight(.semibold))
                Text(node.description).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm))
    }
}

struct SkillPath: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let emoji: String
    let category: ContentCategory
    let nodes: [SkillPathNode]
    var totalDays: Int { nodes.count }

    static let builtIn: [SkillPath] = [
        SkillPath(
            title: "AI Product Management",
            description: "Master the fundamentals of managing AI-powered products from concept to launch.",
            emoji: "🤖",
            category: .aiTechFundamentals,
            nodes: [
                SkillPathNode(title: "What is ML?", description: "Supervised vs unsupervised learning basics"),
                SkillPathNode(title: "AI Product Principles", description: "How to define success for AI features"),
                SkillPathNode(title: "Data Requirements", description: "Training data, labeling, and quality"),
                SkillPathNode(title: "Model Evaluation", description: "Accuracy, precision, recall for PMs"),
                SkillPathNode(title: "LLM Fundamentals", description: "How large language models work"),
                SkillPathNode(title: "AI Ethics & Bias", description: "Responsible AI product decisions"),
                SkillPathNode(title: "AI Metrics", description: "Measuring AI feature success"),
                SkillPathNode(title: "Case Study: AI Assistant", description: "End-to-end AI product design")
            ]
        ),
        SkillPath(
            title: "Interview Bootcamp",
            description: "Crack PM interviews at top tech companies with proven frameworks and practice.",
            emoji: "🎯",
            category: .interviewPrep,
            nodes: [
                SkillPathNode(title: "Product Design Framework", description: "CIRCLES method walkthrough"),
                SkillPathNode(title: "Metrics Questions", description: "North star, guardrails, counter-metrics"),
                SkillPathNode(title: "Estimation Cases", description: "Market sizing and back-of-envelope"),
                SkillPathNode(title: "Strategy Questions", description: "Competitive analysis and positioning"),
                SkillPathNode(title: "Behavioral Stories", description: "STAR method for PM interviews"),
                SkillPathNode(title: "Mock Case: Consumer App", description: "Full interview simulation"),
                SkillPathNode(title: "Mock Case: B2B SaaS", description: "Enterprise product design case"),
                SkillPathNode(title: "Final Review", description: "Tips and common mistakes to avoid")
            ]
        ),
        SkillPath(
            title: "Growth PM Essentials",
            description: "Learn how growth PMs think about acquisition, activation, retention, and revenue.",
            emoji: "📈",
            category: .pmFrameworks,
            nodes: [
                SkillPathNode(title: "AARRR Framework", description: "Pirate metrics deep dive"),
                SkillPathNode(title: "Acquisition Channels", description: "SEO, paid, viral, referral"),
                SkillPathNode(title: "Activation Optimization", description: "First-session design principles"),
                SkillPathNode(title: "Retention Playbook", description: "Cohort analysis and churn reduction"),
                SkillPathNode(title: "Monetization Models", description: "Freemium, subscriptions, marketplace"),
                SkillPathNode(title: "A/B Testing Basics", description: "Statistical significance for PMs"),
                SkillPathNode(title: "Growth Experiments", description: "Rapid experimentation framework")
            ]
        )
    ]
}

struct SkillPathNode {
    let title: String
    let description: String
}
