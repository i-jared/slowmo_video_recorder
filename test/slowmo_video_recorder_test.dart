import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:slowmo_video_recorder/slowmo_video_recorder.dart';
import 'package:slowmo_video_recorder/slowmo_video_recorder_platform_interface.dart';
import 'package:slowmo_video_recorder/slowmo_video_recorder_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSlowmoVideoRecorderPlatform
    with MockPlatformInterfaceMixin
    implements SlowmoVideoRecorderPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SlowmoVideoRecorderPlatform initialPlatform = SlowmoVideoRecorderPlatform.instance;

  test('$MethodChannelSlowmoVideoRecorder is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSlowmoVideoRecorder>());
  });

  test('getPlatformVersion', () async {
    // Force platform override to iOS
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    SlowmoVideoRecorder slowmoVideoRecorderPlugin = SlowmoVideoRecorder();
    MockSlowmoVideoRecorderPlatform fakePlatform = MockSlowmoVideoRecorderPlatform();
    SlowmoVideoRecorderPlatform.instance = fakePlatform;

    expect(await slowmoVideoRecorderPlugin.getPlatformVersion(), '42');

    debugDefaultTargetPlatformOverride = null;
  });
}
