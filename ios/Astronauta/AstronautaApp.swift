import SwiftUI
import UserNotifications

@main
struct AstronautaApp: App {
    private let avisos = AvisosDelegado()

    init() {
        UNUserNotificationCenter.current().delegate = avisos
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
