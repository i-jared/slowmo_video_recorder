import Flutter
import UIKit
import AVFoundation

/// A `FlutterPlatformView` that hosts an `AVCaptureVideoPreviewLayer` for live
/// camera preview.
///
/// The view attempts to reuse the same `AVCaptureSession` managed by
/// `SlowmoVideoRecorderPlugin` so that recording can start without
/// reconfiguring the session. If the plugin hasn't yet created a session, a
/// new one will be created here.
class SlowmoPreviewView: NSObject, FlutterPlatformView {
  private var previewLayer: AVCaptureVideoPreviewLayer?
  private weak var plugin: SlowmoVideoRecorderPlugin?
  private let containerView: UIView

  init(frame: CGRect, plugin: SlowmoVideoRecorderPlugin) {
    self.containerView = UIView(frame: frame)
    self.plugin = plugin
    super.init()

    self.initializePreview()
  }

  private func initializePreview() {
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    // If the plugin already has a session, use it. Otherwise create a minimal
    // one that just provides a preview at 30 fps.
    let session: AVCaptureSession
    if let existing = plugin?.captureSession {
      session = existing
    } else {
      session = AVCaptureSession()
      session.beginConfiguration()
      defer { session.commitConfiguration() }

      // Use the back wide-angle camera by default.
      guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input) else {
        return
      }
      session.addInput(input)
      plugin?.captureSession = session
    }

    // Use a helper view that automatically resizes the preview layer.
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = .resizeAspectFill
    previewLayer.connection?.videoOrientation = .portrait

    // Custom view ensures the layer always matches its bounds.
    let hostingView = PreviewLayerHostingView(layer: previewLayer)
    hostingView.frame = containerView.bounds
    hostingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    containerView.addSubview(hostingView)

    // Ensure the container view itself stretches with its Flutter frame.
    containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    self.previewLayer = previewLayer

    // Listen for device orientation changes to keep the preview properly rotated.
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handleOrientationChange),
                                           name: UIDevice.orientationDidChangeNotification,
                                           object: nil)
  }

  @objc private func handleOrientationChange() {
    guard let connection = previewLayer?.connection, connection.isVideoOrientationSupported else { return }
    switch UIDevice.current.orientation {
    case .portrait:
      connection.videoOrientation = .portrait
    case .landscapeLeft:
      // When device is in landscapeLeft, the video is landscapeRight.
      connection.videoOrientation = .landscapeRight
    case .landscapeRight:
      connection.videoOrientation = .landscapeLeft
    case .portraitUpsideDown:
      connection.videoOrientation = .portraitUpsideDown
    default:
      break
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func view() -> UIView {
    return containerView
  }
}

/// Factory responsible for creating `SlowmoPreviewView` instances.
class SlowmoPreviewViewFactory: NSObject, FlutterPlatformViewFactory {
  private weak var plugin: SlowmoVideoRecorderPlugin?

  init(plugin: SlowmoVideoRecorderPlugin) {
    self.plugin = plugin
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return SlowmoPreviewView(frame: frame, plugin: plugin!)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

/// A UIView that hosts a `AVCaptureVideoPreviewLayer` and keeps it sized to
/// fill the view's bounds whenever they change.
private class PreviewLayerHostingView: UIView {
  private let hostedLayer: AVCaptureVideoPreviewLayer

  init(layer: AVCaptureVideoPreviewLayer) {
    self.hostedLayer = layer
    super.init(frame: .zero)
    self.layer.addSublayer(hostedLayer)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    hostedLayer.frame = self.bounds
  }
} 