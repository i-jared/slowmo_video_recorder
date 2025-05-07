import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:slowmo_video_recorder/slowmo_video_recorder_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSlowmoVideoRecorder platform = MethodChannelSlowmoVideoRecorder();
  const MethodChannel channel = MethodChannel('slowmo_video_recorder');

  setUp(() {
    // Ensure TargetPlatform reports as iOS to pass the platform guard.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
