import SwiftUI
import SwiftData
import AVFoundation

@MainActor
class CameraModel: ObservableObject {
    
    @Published var hasPermission = false
    @Published var errorMessage = ""
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            hasPermission = true
            errorMessage = ""
        case .denied, .restricted:
            hasPermission = false
            errorMessage = "Camera access required. Enable in Settings."
        case .notDetermined:
            hasPermission = false
            errorMessage = ""
        @unknown default:
            hasPermission = false
        }
    }
    
    func requestPermission() async -> Bool {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        hasPermission = granted
        errorMessage = granted ? "" : "Camera access denied. Enable in Settings."
        return granted
        
    }
}
