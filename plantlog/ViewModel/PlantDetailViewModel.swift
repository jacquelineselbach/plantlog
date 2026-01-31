import Foundation
import SwiftUI

@MainActor
final class PlantDetailViewModel: ObservableObject {
    
    @Published var plant: PlantModel
    @Published var showWaterSheet: Bool = false
    @Published var showCalendarSheet: Bool = false
    @Published var showEditSheet: Bool = false
    @Published var amountMl: Int?
    @Published var selectedDay: DateComponents?
    @Published var isImageExpanded: Bool = false
    @Published var errorMessage: String?
    
    private let repository: PlantRepository
    private let notificationService: NotificationServiceProtocol
    private let calendar: Calendar
        
    var scheduleDescription: String {
        let time = plant.wateringTime.formatted(date: .omitted, time: .shortened)
        switch plant.scheduleType {
        case .interval:
            return "Every \(plant.wateringIntervalDays) days at \(time)"
        case .weekday:
            if let weekday = plant.weekday, (1...7).contains(weekday) {
                let name = calendar.weekdaySymbols[weekday - 1]
                return "Every \(name) at \(time)"
            } else {
                return "Specific weekday at \(time)"
            }
        }
    }
    
    var nextWateringDateString: String {
        plant.nextWateringDate(from: .now)
            .formatted(date: .abbreviated, time: .shortened)
    }
    
    var lastWateredString: String {
        guard let last = recentWateringEvents.first else {
            return "—"
        }
        return last.date.formatted(date: .abbreviated, time: .shortened)
    }
    
    var recentWateringEvents: [WateringModel] {
        repository.getWateringHistory(for: plant, limit: 5)
    }
    
    var hasWateringHistory: Bool {
        !plant.wateringHistory.isEmpty
    }
        
    init(
        plant: PlantModel,
        repository: PlantRepository,
        notificationService: NotificationServiceProtocol = NotificationServiceWrapper(),
        calendar: Calendar = .current
    ) {
        self.plant = plant
        self.repository = repository
        self.notificationService = notificationService
        self.calendar = calendar
    }
        
    func addWateringEvent() {
        do {
            try repository.addWateringEvent(
                to: plant,
                amountMl: amountMl,
                date: .now
            )
            notificationService.scheduleWateringNotification(for: plant)
            
            amountMl = nil
            showWaterSheet = false
            
            objectWillChange.send()
        } catch {
            errorMessage = "Failed to add watering event: \(error.localizedDescription)"
        }
    }
    
    func updatePlant(_ updatedPlant: PlantModel) {
        do {
            try repository.updatePlant(updatedPlant)
            notificationService.scheduleWateringNotification(for: updatedPlant)
            
            plant = updatedPlant
            
            objectWillChange.send()
        } catch {
            errorMessage = "Failed to update plant: \(error.localizedDescription)"
        }
    }
    
    func deletePlant() {
        do {
            try repository.deletePlant(plant)
            notificationService.cancelNotification(for: plant)
            
            showEditSheet = false
        } catch {
            errorMessage = "Failed to delete plant: \(error.localizedDescription)"
        }
    }
    
    func toggleImageExpansion() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            isImageExpanded.toggle()
        }
    }
    
    func cancelWatering() {
        amountMl = nil
        showWaterSheet = false
    }
}
