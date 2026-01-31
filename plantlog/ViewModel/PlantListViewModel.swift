import Foundation
import SwiftData
import Combine

@MainActor
final class PlantListViewModel: ObservableObject {

    @Published var plants: [PlantModel] = []
    @Published var searchText: String = ""
    @Published var intervalFilter: IntervalFilter = .all
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingCreate: Bool = false
    @Published var editingPlant: PlantModel?
    @Published var selectedPlant: PlantModel?
    
    private let repository: PlantRepository
    private let notificationService: NotificationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var filteredPlants: [PlantModel] {
        plants.filter { plant in
            let matchesSearch = searchText.isEmpty || matchesSearchQuery(plant)
            let matchesInterval = matchesIntervalFilter(plant)
            return matchesSearch && matchesInterval
        }
    }
    
    init(
        repository: PlantRepository,
        notificationService: NotificationServiceProtocol = NotificationServiceWrapper()
    ) {
        self.repository = repository
        self.notificationService = notificationService
        loadPlants()
    }
        
    func loadPlants() {
        isLoading = true
        errorMessage = nil
        
        do {
            plants = try repository.fetchAllPlants()
            isLoading = false
        } catch {
            errorMessage = "Failed to load plants: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func createPlant(_ plant: PlantModel) {
        do {
            try repository.savePlant(plant)
            notificationService.scheduleWateringNotification(for: plant)
            loadPlants()
        } catch {
            errorMessage = "Failed to save plant: \(error.localizedDescription)"
        }
    }
    
    func updatePlant(_ plant: PlantModel) {
        do {
            try repository.updatePlant(plant)
            notificationService.scheduleWateringNotification(for: plant)
            loadPlants()
        } catch {
            errorMessage = "Failed to update plant: \(error.localizedDescription)"
        }
    }
    
    func deletePlant(_ plant: PlantModel) {
        do {
            try repository.deletePlant(plant)
            loadPlants()
        } catch {
            errorMessage = "Failed to delete plant: \(error.localizedDescription)"
        }
    }
    
    func handleNotificationTap(plantID: UUID) {
        guard let plant = plants.first(where: { $0.id == plantID }) else { return }
        selectedPlant = plant
    }
        
    private func matchesSearchQuery(_ plant: PlantModel) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return plant.name.lowercased().contains(query) ||
               plant.species.lowercased().contains(query)
    }
    
    private func matchesIntervalFilter(_ plant: PlantModel) -> Bool {
        let interval = plant.wateringIntervalDays
        switch intervalFilter {
        case .all:
            return true
        case .lessThan7:
            return interval < 7
        case .between7And14:
            return (7...14).contains(interval)
        case .moreThan14:
            return interval > 14
        }
    }
}

enum IntervalFilter: String, CaseIterable, Identifiable {
    case all
    case lessThan7
    case between7And14
    case moreThan14

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all:
            return "All Plants"
        case .lessThan7:
            return "Next 7 days"
        case .between7And14:
            return "7 to 14 days"
        case .moreThan14:
            return "More than 14 days"
        }
    }
    
    var icon: String {
        switch self {
        case .all:
            return "list.bullet"
        case .lessThan7:
            return "drop.fill"
        case .between7And14:
            return "calendar"
        case .moreThan14:
            return "calendar.badge.clock"
        }
    }
}
