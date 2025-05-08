import Flutter
import UIKit
import AVFoundation

public class SlowmoVideoRecorderPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "slowmo_video_recorder", binaryMessenger: registrar.messenger())
    let instance = SlowmoVideoRecorderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

var captureSession: AVCaptureSession?
var videoOutput: AVCaptureMovieFileOutput?
var outputFileURL: URL?
var recordingResult: FlutterResult?  // to store the Flutter result for async callback

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
      case "startRecording":
          guard let args = call.arguments as? [String: Any],
                let fps = args["fps"] as? Int,
                let resolution = args["resolution"] as? String else {
              result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
              return
          }
          startSlowMoCapture(fps: fps, resolution: resolution, flutterResult: result)
      case "stopRecording":
          stopSlowMoCapture(flutterResult: result)
      case "getPlatformVersion":
          result("iOS " + UIDevice.current.systemVersion)
      default:
          result(FlutterMethodNotImplemented)
      }
  }


  func startSlowMoCapture(fps: Int, resolution: String, flutterResult: @escaping FlutterResult) {
    // 1. Create session
    let session = AVCaptureSession()
    session.beginConfiguration()
    defer { session.commitConfiguration() }  // commit config at end
    
    // 2. Select camera (back camera for slow-mo)
    guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
        flutterResult(FlutterError(code: "NO_CAMERA", message: "No camera available", details: nil))
        return
    }
    
    // 3. Add video input
    do {
        let videoInput = try AVCaptureDeviceInput(device: videoDevice)
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
    } catch {
        flutterResult(FlutterError(code: "INPUT_ERROR", message: "Could not add video input: \(error)", details: nil))
        return
    }
    
    // 4. Add audio input (microphone)
    if let audioDevice = AVCaptureDevice.default(for: .audio) {
        do {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
        } catch {
            // If audio input fails, continue without audio
        }
    }
    
    // 5. Prepare movie file output
    let movieOutput = AVCaptureMovieFileOutput()
    if session.canAddOutput(movieOutput) {
        session.addOutput(movieOutput)
    }
    // Set a maximum recording duration if desired (optional)
    // movieOutput.maxRecordedDuration = CMTime(seconds: 60, preferredTimescale: 1)
    
    // Save to instance variables
    self.captureSession = session
    self.videoOutput = movieOutput

    // 6. Select best format for the requested resolution and fps
    let desiredWidth: Int32
    let desiredHeight: Int32
    if resolution == "1080p" {
        desiredWidth = 1920; desiredHeight = 1080
    } else {
        // default to 720p
        desiredWidth = 1280; desiredHeight = 720
    }
    
    var selectedFormat: AVCaptureDevice.Format?
    var selectedFrameRateRange: AVFrameRateRange?
    
    for format in videoDevice.formats {
        // Check format resolution
        let desc = format.formatDescription
        let dims = CMVideoFormatDescriptionGetDimensions(desc)
        let width = dims.width
        let height = dims.height
        if width < desiredWidth || height < desiredHeight {
            continue  // skip formats with lower resolution than desired
        }
        // Check max frame rate in format's supported ranges
        for range in format.videoSupportedFrameRateRanges {
            if range.maxFrameRate >= Double(fps) {
                // Found a format that supports the desired fps at at least the desired resolution
                selectedFormat = format
                selectedFrameRateRange = range
                break
            }
        }
        if selectedFormat != nil { break }
    }
    
    guard let bestFormat = selectedFormat, let frameRateRange = selectedFrameRateRange else {
        session.commitConfiguration()
        flutterResult(FlutterError(code: "FORMAT_NOT_FOUND", message: "No suitable camera format for \(fps) FPS at \(resolution)", details: nil))
        return
    }
    
    // 7. Configure the device with the selected format
    do {
        try videoDevice.lockForConfiguration()
        videoDevice.activeFormat = bestFormat
        // Set the device to the exact desired FPS by adjusting min/max frame durations
        let duration = CMTime(value: 1, timescale: Int32(fps))
        videoDevice.activeVideoMinFrameDuration = duration
        videoDevice.activeVideoMaxFrameDuration = duration
        videoDevice.unlockForConfiguration()
    } catch {
        session.commitConfiguration()
        flutterResult(FlutterError(code: "CONFIG_ERROR", message: "Could not configure camera: \(error)", details: nil))
        return
    }
    // 8. Start the capture session
    session.commitConfiguration()
    session.startRunning()
    
    // 9. Begin recording to a temporary file
    let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
    let fileName = "slowmo_\(Int(Date().timeIntervalSince1970)).mov"
    let fileURL = tempDir.appendingPathComponent(fileName)
    self.outputFileURL = fileURL  // store for reference
    
    // Start recording
    movieOutput.startRecording(to: fileURL, recordingDelegate: self)

    // Immediately notify Flutter that recording started successfully.
    flutterResult(true)
  }

  func stopSlowMoCapture(flutterResult: @escaping FlutterResult) {
    guard let movieOutput = self.videoOutput, movieOutput.isRecording else {
        flutterResult(FlutterError(code: "NOT_RECORDING", message: "No active recording to stop", details: nil))
        return
    }
    // The result will be sent in delegate callback, store it
    self.recordingResult = flutterResult
    movieOutput.stopRecording()
    // (The AVCaptureFileOutputRecordingDelegate will handle returning the file path)
  }
}


extension SlowmoVideoRecorderPlugin: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, 
                            didFinishRecordingTo outputFileURL: URL, 
                            from connections: [AVCaptureConnection], 
                            error: Error?) {
        // This is called when recording stops or an error occurs.
        defer { self.recordingResult = nil }
        if let err = error {
            // Pass error back to Flutter
            recordingResult?(FlutterError(code: "REC_ERROR", message: "Recording failed: \(err.localizedDescription)", details: nil))
        } else {
            // Return the file path to Flutter
            recordingResult?(outputFileURL.path)
        }
    }
    public func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Optionally, handle any setup when recording starts (not used here).
    }
}
