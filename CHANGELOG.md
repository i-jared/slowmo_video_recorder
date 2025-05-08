## 0.0.1

Initial release of slowmo video recorder. iOS implementation only.

## 0.0.2

Fixed critical issue in package that prevented recording success.
Added example app.

## 0.0.3

Added live camera preview support:
* `SlowmoCameraPreview` widget renders an `AVCaptureVideoPreviewLayer` on iOS.
* Example app updated to show the preview and playback interchangeably.
* Internals: platform view factory & session reuse on the iOS side.
