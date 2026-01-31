import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class PlantFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var species: String = ""
    @Published var scheduleType: WateringScheduleType = .interval
    @Published var wateringIntervalDays: Int = 7
    @Published var startDate: Date = .now
    @Published var weekday: Int? = 2
    @Published var wateringTime: Date
    @Published var imageData: Data?
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var showCameraView: Bool = false
    @Published var showPermissionAlert: Bool = false
    
    private let existingPlant: PlantModel?
    let cameraModel: CameraModel
    
    var isEditing: Bool {
        existingPlant != nil
    }
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var weekdaySymbols: [String] {
        Calendar.current.weekdaySymbols
    }
        
    init(existingPlant: PlantModel? = nil, cameraModel: CameraModel = CameraModel()) {
        self.existingPlant = existingPlant
        self.cameraModel = cameraModel
        
        self.wateringTime = Calendar.current.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: .now
        ) ?? .now
        
        if let plant = existingPlant {
            self.name = plant.name
            self.species = plant.species
            self.scheduleType = plant.scheduleType
            self.wateringIntervalDays = plant.wateringIntervalDays
            self.startDate = plant.startDate
            self.weekday = plant.weekday
            self.imageData = plant.imageData
            self.wateringTime = plant.wateringTime
        }
    }
        
    func buildPlant() -> PlantModel {
        let plant = existingPlant ?? PlantModel()
        plant.name = name
        plant.species = species
        plant.scheduleType = scheduleType
        plant.wateringIntervalDays = wateringIntervalDays
        plant.startDate = startDate
        plant.weekday = weekday
        plant.imageData = imageData
        plant.wateringTime = wateringTime
        return plant
    }
    
    func loadSelectedPhoto() async {
        guard let selectedPhoto else { return }
        do {
            if let data = try await selectedPhoto.loadTransferable(type: Data.self) {
                await MainActor.run {
                    self.imageData = data
                    self.selectedPhoto = nil
                }
            }
        } catch {
            print("Photo load error: \(error)")
        }
    }
    
    func handleCameraCapture(_ data: Data) {
        imageData = data
    }
    
    func checkCameraPermission() {
        cameraModel.checkPermission()
    }
    
    func openCamera() {
        cameraModel.checkPermission()
        if cameraModel.hasPermission {
            showCameraView = true
        } else {
            Task {
                let granted = await cameraModel.requestPermission()
                if granted {
                    showCameraView = true
                } else {
                    showPermissionAlert = true
                }
            }
        }
    }
}
