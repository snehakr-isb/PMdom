import WidgetKit
import SwiftUI

@main
struct PMDailyQuestionsWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallStreakWidget()
        MediumProgressWidget()
        LargeLeaderWidget()
    }
}
