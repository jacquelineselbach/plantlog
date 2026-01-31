import UserNotifications
import Foundation


protocol NotificationServiceProtocol {
    
    func scheduleWateringNotification(for plant: PlantModel)
    func cancelNotification(for plant: PlantModel)
}

struct NotificationServiceWrapper: NotificationServiceProtocol {
    func scheduleWateringNotification(for plant: PlantModel) {
        NotificationService.scheduleWateringNotification(for: plant)
    }
    
    func cancelNotification(for plant: PlantModel) {
        let identifier = "plant-\(plant.id.uuidString)"
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
        
    }
}
