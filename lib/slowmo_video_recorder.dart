import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'slowmo_video_recorder_platform_interface.dart';
export 'slowmo_camera_preview.dart';

/// Primary API for interacting with the slow-motion recorder.
///
/// The plugin currently supports iOS only. Calling any of these methods on
/// other platforms will throw an [UnsupportedError].
class SlowmoVideoRecorder {
  // We purposefully keep a single [MethodChannel] shared across all instances
  // because only one recording session can be active at a time.
  static const MethodChannel _channel = MethodChannel('slowmo_video_recorder');

  /// Starts a slow-motion recording on the native side.
  ///
  /// [fps] The desired frame-rate. Most modern iPhone models support 120 fps
  /// and 240 fps at 720p or 1080p.
  ///
  /// [resolution] Accepts `"720p"` or `"1080p"`. Defaults to `"720p"`.
  Future<void> startRecording({int fps = 120, String resolution = "720p"}) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnsupportedError('slowmo_video_recorder: startRecording is only available on iOS.');
    }
    final args = {"fps": fps, "resolution": resolution};
    await _channel.invokeMethod<void>('startRecording', args);
  }

  /// Stops the active recording and returns the absolute file path (on the
  /// host device) of the captured video, or `null` if an error occurred.
  Future<String?> stopRecording() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnsupportedError('slowmo_video_recorder: stopRecording is only available on iOS.');
    }
    final String? filePath = await _channel.invokeMethod<String>('stopRecording');
    return filePath;
  }

  /// Returns a string describing the current platform version, mainly used
  /// for testing and diagnostics.
  Future<String?> getPlatformVersion() async {
    // We delegate the call to the platform-specific implementation registered
    // in [SlowmoVideoRecorderPlatform]. This allows mocking in tests and
    // graceful fallback on unsupported platforms.
    return SlowmoVideoRecorderPlatform.instance.getPlatformVersion();
  }
}

