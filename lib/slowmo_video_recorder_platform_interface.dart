import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'slowmo_video_recorder_method_channel.dart';

abstract class SlowmoVideoRecorderPlatform extends PlatformInterface {
  /// Constructs a SlowmoVideoRecorderPlatform.
  SlowmoVideoRecorderPlatform() : super(token: _token);

  static final Object _token = Object();

  static SlowmoVideoRecorderPlatform _instance = MethodChannelSlowmoVideoRecorder();

  /// The default instance of [SlowmoVideoRecorderPlatform] to use.
  ///
  /// Defaults to [MethodChannelSlowmoVideoRecorder].
  static SlowmoVideoRecorderPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SlowmoVideoRecorderPlatform] when
  /// they register themselves.
  static set instance(SlowmoVideoRecorderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
