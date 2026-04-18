import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationHour") private var notificationHour = 8
    @AppStorage("notificationMinute") private var notificationMinute = 0
    @State private var selectedTime = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Notifications") {
                    DatePicker("Daily Reminder", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .onChange(of: selectedTime) { _, newTime in
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: newTime)
                            notificationHour = comps.hour ?? 8
                            notificationMinute = comps.minute ?? 0
                            NotificationService.shared.scheduleDailyReminder(
                                hour: notificationHour,
                                minute: notificationMinute
                            )
                        }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Questions", value: "\(QuestionRepository.shared.allQuestions().count) available")
                }

                Section {
                    Button("Reset Onboarding", role: .destructive) {
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                var comps = DateComponents()
                comps.hour = notificationHour
                comps.minute = notificationMinute
                selectedTime = Calendar.current.date(from: comps) ?? Date()
            }
        }
    }
}
