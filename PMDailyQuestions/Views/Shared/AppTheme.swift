import SwiftUI

enum AppTheme {
    static let accent = Color("AccentColor")
    static let streakFlame = Color.orange
    static let correctGreen = Color(red: 0.18, green: 0.80, blue: 0.44)
    static let wrongRed = Color(red: 0.95, green: 0.27, blue: 0.27)
    static let cardBackground = Color(.secondarySystemBackground)
    static let surface = Color(.systemBackground)

    enum CategoryColor {
        static func color(for category: ContentCategory) -> Color {
            switch category {
            case .interviewPrep: return .blue
            case .pmFrameworks: return .purple
            case .currentEvents: return .orange
            case .aiTechFundamentals: return .teal
            }
        }
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
