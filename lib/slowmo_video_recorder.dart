
import 'package:flutter/services.dart';

class SlowMoVideoRecorder {
  static const MethodChannel _channel = MethodChannel('slowmo_video_recorder');

  // Start recording slow-mo video with given options
  static Future<void> startRecording({int fps = 120, String resolution = "720p"}) async {
    // Pass configuration to iOS as arguments
    final args = {"fps": fps, "resolution": resolution};
    await _channel.invokeMethod('startRecording', args);
  }

  // Stop recording and get the file path of the video
  static Future<String?> stopRecording() async {
    final String? filePath = await _channel.invokeMethod('stopRecording');
    return filePath;
  }
}

