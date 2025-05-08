# 📹 slowmo_video_recorder

Slow-motion video recording made easy for Flutter apps ( **iOS-only** ).

The plugin provides a thin wrapper around **AVFoundation** allowing you to
record 120 fps or 240 fps clips at 720p / 1080p with a single method call.

| Platform | iOS |
|----------|-----|
| Minimum OS | 12.0 |

---

## ✨ Features

• Live camera preview widget (`SlowmoCameraPreview`).<br>
• Start / stop high-frame-rate recordings.<br>
• Choose frame-rate (`fps`) and resolution (`"720p"`, `"1080p"`).<br>
• Returns the absolute file path (`.mov`) on completion.<br>

> Android or web support is **not** planned.  You can still import the package
> on these platforms; calls will throw `UnsupportedError`.

---

## 🚀 Quick start

Add to `pubspec.yaml`:

```yaml
dependencies:
  slowmo_video_recorder: ^0.0.3
```

### iOS setup

1. Update your *Info.plist*:

```xml
<key>NSCameraUsageDescription</key>
<string>This app requires camera access to record slow-motion videos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app records audio while capturing videos.</string>
```

2. (Xcode 15+) Verify `PrivacyInfo.xcprivacy` is bundled (already included in
   the pod). Edit if you need to declare additional data usage.

### Code sample

```dart
final recorder = SlowmoVideoRecorder();

// Start recording at 240 fps / 1080p
await recorder.startRecording(fps: 240, resolution: '1080p');

// …wait or display UI…

final path = await recorder.stopRecording();
print('Video saved to: $path');
```

---

## 🔧 API reference

| Method | Description |
|--------|-------------|
| `startRecording({int fps = 120, String resolution = '720p'})` | Begins a session. |
| `stopRecording()` → `Future<String?>` | Stops and returns file path. |
| `getPlatformVersion()` | Diagnostic helper. |

---

## 📝 License

Released under the MIT license. See [LICENSE](LICENSE) for details.

