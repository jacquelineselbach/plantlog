import XCTest
import SwiftData
@testable import plantlog

@MainActor
final class PlantListViewModelTests_XCTest: XCTestCase {
    
    var container: ModelContainer!
    var viewModel: PlantListViewModel!
    var repository: PlantRepository!
    
    override func setUp() {
        super.setUp()
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(
            for: PlantModel.self, WateringModel.self,
            configurations: config
        )
        repository = PlantRepository(modelContext: container.mainContext)
        
        let mockNotificationService = MockNotificationService()
        viewModel = PlantListViewModel(
            repository: repository,
            notificationService: mockNotificationService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        repository = nil
        container = nil
        super.tearDown()
    }
    
    
    func testLoadPlantsSuccessfully() throws {
        let plant = PlantModel(name: "Monstera", species: "Monstera deliciosa")
        try repository.savePlant(plant)
        viewModel.loadPlants()
        XCTAssertEqual(viewModel.plants.count, 1)
        XCTAssertEqual(viewModel.plants.first?.name, "Monstera")
    }
    
    func testSearchFiltering() throws {
        try repository.savePlant(PlantModel(name: "Monstera", species: "Monstera deliciosa"))
        try repository.savePlant(PlantModel(name: "Pothos", species: "Epipremnum aureum"))
        try repository.savePlant(PlantModel(name: "Snake Plant", species: "Sansevieria"))
        
        viewModel.loadPlants()
        
        XCTAssertEqual(viewModel.filteredPlants.count, 3)
        
        viewModel.searchText = "monstera"
        XCTAssertEqual(viewModel.filteredPlants.count, 1)
        XCTAssertEqual(viewModel.filteredPlants.first?.name, "Monstera")
        
        viewModel.searchText = "sansevieria"
        XCTAssertEqual(viewModel.filteredPlants.count, 1)
        XCTAssertEqual(viewModel.filteredPlants.first?.name, "Snake Plant")
        
        viewModel.searchText = "orchid"
        XCTAssertTrue(viewModel.filteredPlants.isEmpty)
    }
    
    func testIntervalFiltering() throws {
        try repository.savePlant(PlantModel(
            name: "Cactus",
            species: "Cactaceae",
            wateringIntervalDays: 14
        ))
        try repository.savePlant(PlantModel(
            name: "Fern",
            species: "Nephrolepis",
            wateringIntervalDays: 3
        ))
        try repository.savePlant(PlantModel(
            name: "Succulent",
            species: "Echeveria",
            wateringIntervalDays: 21
        ))
        
        viewModel.loadPlants()

    }
    
    func testCreatePlant() throws {
        let newPlant = PlantModel(name: "New Plant", species: "Test Species")
        viewModel.createPlant(newPlant)
        
        XCTAssertEqual(viewModel.plants.count, 1)
        XCTAssertEqual(viewModel.plants.first?.name, "New Plant")
    }
    
    func testDeletePlant() throws {
        let plant = PlantModel(name: "To Delete", species: "Test")
        try repository.savePlant(plant)
        
        viewModel.loadPlants()
        XCTAssertEqual(viewModel.plants.count, 1)
        
        viewModel.deletePlant(plant)
        XCTAssertTrue(viewModel.plants.isEmpty)
    }
    
    func testUpdatePlant() throws {
        let plant = PlantModel(name: "Original Name", species: "Test")
        try repository.savePlant(plant)
        
        viewModel.loadPlants()
        XCTAssertEqual(viewModel.plants.first?.name, "Original Name")
        
        plant.name = "Updated Name"
        viewModel.updatePlant(plant)
        
        XCTAssertEqual(viewModel.plants.first?.name, "Updated Name")
    }
    
    func testNotificationTapNavigation() throws {
        let plant1 = PlantModel(name: "Plant 1", species: "Species 1")
        let plant2 = PlantModel(name: "Plant 2", species: "Species 2")
        try repository.savePlant(plant1)
        try repository.savePlant(plant2)
        
        viewModel.loadPlants()
        
        viewModel.handleNotificationTap(plantID: plant2.id)
        
        XCTAssertNotNil(viewModel.selectedPlant)
        XCTAssertEqual(viewModel.selectedPlant?.name, "Plant 2")
    }
    
    func testCombinedFiltering() throws {
        try repository.savePlant(PlantModel(
            name: "Monstera",
            species: "Monstera deliciosa",
            wateringIntervalDays: 7
        ))
        try repository.savePlant(PlantModel(
            name: "Fern",
            species: "Nephrolepis",
            wateringIntervalDays: 3
        ))
        try repository.savePlant(PlantModel(
            name: "Money Tree",
            species: "Pachira aquatica",
            wateringIntervalDays: 10
        ))
        
        viewModel.loadPlants()
        
        viewModel.searchText = "monstera"
        viewModel.intervalFilter = .between7And14
        
        XCTAssertEqual(viewModel.filteredPlants.count, 1)
        XCTAssertEqual(viewModel.filteredPlants.first?.name, "Monstera")
        
        viewModel.searchText = "fern"
        XCTAssertEqual(viewModel.filteredPlants.count, 0) // Fern is < 7 days
    }
}


class MockNotificationService: NotificationServiceProtocol {
    var scheduledPlants: [PlantModel] = []
    var cancelledPlants: [PlantModel] = []
    
    func scheduleWateringNotification(for plant: PlantModel) {
        scheduledPlants.append(plant)
    }
    
    func cancelNotification(for plant: PlantModel) {
        cancelledPlants.append(plant)
    }
}
