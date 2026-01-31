import Foundation
import SwiftData

@MainActor
final class PlantRepository: ObservableObject {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
        
    func fetchAllPlants() throws -> [PlantModel] {
        let descriptor = FetchDescriptor<PlantModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchPlant(by id: UUID) throws -> PlantModel? {
        let descriptor = FetchDescriptor<PlantModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func savePlant(_ plant: PlantModel) throws {
        modelContext.insert(plant)
        try modelContext.save()
    }
    
    func updatePlant(_ plant: PlantModel) throws {
        try modelContext.save()
    }
    
    func deletePlant(_ plant: PlantModel) throws {
        modelContext.delete(plant)
        try modelContext.save()
    }
        
    func addWateringEvent(to plant: PlantModel, amountMl: Int?, date: Date = .now) throws {
        let event = WateringModel(date: date, amountMl: amountMl)
        plant.wateringHistory.insert(event, at: 0)
        plant.startDate = date
        try modelContext.save()
    }
    
    func getWateringHistory(for plant: PlantModel, limit: Int? = nil) -> [WateringModel] {
        let sorted = plant.wateringHistory.sorted { $0.date > $1.date }
        if let limit = limit {
            return Array(sorted.prefix(limit))
        }
        return sorted
    }
}
