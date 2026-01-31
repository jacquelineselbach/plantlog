import SwiftUI
import SwiftData
import AVFoundation

struct CameraCaptureView: View {
    
    @ObservedObject var cameraModel: CameraModel
    let onPhotoCaptured: (Data) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraSession()

    var body: some View {
        ZStack {
            CameraPreviewUIViewRepresentable(camera: camera)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack {
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                        .font(.headline)
                        .accessibilityLabel("Cancel photo capture")
                        .accessibilityHint("Closes the camera without taking a photo")
                    Spacer()
                }
                .padding()

                Spacer()

                Button(action: capturePhoto) {
                    Circle()
                        .fill(.white)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.5), lineWidth: 4)
                                .frame(width: 90, height: 90)
                        )
                }
                .disabled(!camera.isReady)
                .opacity(camera.isReady ? 1 : 0.5)
                .padding(.bottom)
                .accessibilityLabel("Take photo")
                .accessibilityHint(camera.isReady ? "Captures the photo" : "Camera is not ready yet")
                .accessibilityAddTraits(.isButton)
            }
        }
        .onAppear {
            camera.startSession()
        }
        .onDisappear {
            camera.stopSession()
            
        }
    }

    private func capturePhoto() {
        camera.capturePhoto { data in
            dismiss()
            if let data {
                onPhotoCaptured(data)
            }
        }
    }
}
