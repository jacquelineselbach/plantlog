import SwiftUI
import SwiftData
import AVFoundation

class CameraSession: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    @Published var isReady = false
    private var photoCaptureCompletion: ((Data?) -> Void)?
    private var videoDevice: AVCaptureDevice?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        
        videoDevice = device
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            if #available(iOS 16.0, *) {
                photoOutput.maxPhotoQualityPrioritization = .quality
            }
        }
        
        session.commitConfiguration()
    }
    
    @MainActor
    func startSession() {
        guard !session.isRunning else { return }
        session.startRunning()
        isReady = true
    }
    
    func stopSession() {
        session.stopRunning()
        isReady = false
    }
    
    func capturePhoto(completion: @escaping (Data?) -> Void) {
        photoCaptureCompletion = completion
        
        let settings = AVCapturePhotoSettings()
        
        if #available(iOS 16.0, *),
           let device = videoDevice,
           let maxDimensions = device.activeFormat.supportedMaxPhotoDimensions.last {
            settings.maxPhotoDimensions = maxDimensions
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            print("Camera error:", error)
            photoCaptureCompletion?(nil)
            return
        }
        
        photoCaptureCompletion?(photo.fileDataRepresentation())
        photoCaptureCompletion = nil
        
    }
}
