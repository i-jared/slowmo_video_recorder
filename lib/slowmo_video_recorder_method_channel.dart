import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'slowmo_video_recorder_platform_interface.dart';

/// An implementation of [SlowmoVideoRecorderPlatform] that uses method channels.
class MethodChannelSlowmoVideoRecorder extends SlowmoVideoRecorderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('slowmo_video_recorder');

  @override
  Future<String?> getPlatformVersion() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnsupportedError('slowmo_video_recorder: This plugin currently supports iOS only.');
    }

    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
