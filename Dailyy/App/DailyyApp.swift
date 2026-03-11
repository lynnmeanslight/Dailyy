import SwiftUI
import UserNotifications

@main
struct DailyyApp: App {
    let persistence = PersistenceController.shared
    @StateObject private var localization = LocalizationManager.shared

    init() {
        // Request notification permissions at launch
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(context: persistence.container.viewContext)
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(localization)
                .frame(minWidth: 900, idealWidth: 1000, maxWidth: .infinity, minHeight: 600, idealHeight: 800, maxHeight: .infinity)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}   // remove default File > New
        }
    }
}
