import SwiftUI
import SwiftData
import UserNotifications

@main
struct plantlogApp: App {
    static let sharedContainer: ModelContainer = {
        let schema = Schema([PlantModel.self, WateringModel.self])
        return try! ModelContainer(for: schema)
    }()

    private let notificationDelegate = NotificationDelegate()

    init() {
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        Task { await NotificationService.requestAuthorization() }
        loadRocketSimConnect()
    }

    var body: some Scene {
        WindowGroup {
            PlantListView(modelContext: Self.sharedContainer.mainContext)
        }
        .modelContainer(Self.sharedContainer)
    }
}

private func loadRocketSimConnect() {
    #if DEBUG
    guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
        print("Failed to load linker framework")
        return
    }
    print("RocketSim Connect successfully linked")
    #endif
}
