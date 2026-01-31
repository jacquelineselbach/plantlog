import UIKit
import AVFoundation

class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override var isAccessibilityElement: Bool {
        get { true }
        set { }
    }

    override var accessibilityLabel: String? {
        get { "Camera preview" }
        set { }
    }

    override var accessibilityHint: String? {
        get { "Shows live camera video feed" }
        set { }
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get { .updatesFrequently }
        set { }
    }
}
