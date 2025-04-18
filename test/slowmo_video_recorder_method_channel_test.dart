import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slowmo_video_recorder/slowmo_video_recorder_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSlowmoVideoRecorder platform = MethodChannelSlowmoVideoRecorder();
  const MethodChannel channel = MethodChannel('slowmo_video_recorder');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
