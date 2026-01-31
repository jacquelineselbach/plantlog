import Foundation
import UserNotifications

enum NotificationService {

    static func requestAuthorization() async {
        do {
            _ = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification permission error:", error)
        }
    }

    static func scheduleWateringNotification(for plant: PlantModel) {
        let nextDate = plant.nextWateringDate()

        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: nextDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: comps,
            repeats: false
        )

        let content = UNMutableNotificationContent()
        content.title = "Water \(plant.name)"
        content.body = "Time to water \(plant.species)."
        content.sound = .default

        content.userInfo["plantID"] = plant.id.uuidString

        let identifier = "plant-\(plant.id.uuidString)"

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        center.add(request)
        
    }
    
}
