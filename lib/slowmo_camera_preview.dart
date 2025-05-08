import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that renders a live camera preview provided by the native side
/// of this plugin.
///
/// On iOS, the preview is backed by an `AVCaptureVideoPreviewLayer` that is
/// hosted inside an `UIView`. On any other platform the widget simply
/// displays an empty [SizedBox].
///
/// The widget can be placed anywhere in the widget tree.  Simply wrap it in
/// an [AspectRatio] or [FittedBox] to constrain its dimensions.
///
/// Example:
/// ```dart
/// SlowmoCameraPreview(
///   aspectRatio: 16 / 9,
/// )
/// ```
class SlowmoCameraPreview extends StatelessWidget {
  /// Constructs the preview.
  const SlowmoCameraPreview({super.key, this.aspectRatio});

  /// A helper to embed the preview in the desired aspect ratio.
  ///
  /// If `null`, the preview view will expand to fill its parent while keeping
  /// its own intrinsic size.
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      // The plugin currently supports iOS only. On other platforms we render
      // a placeholder to avoid crashes in the widget tree.
      return const SizedBox.shrink();
    }

    Widget view = const UiKitView(
      viewType: _kPreviewViewType,
      creationParams: null,
      creationParamsCodec: StandardMessageCodec(),
    );

    if (aspectRatio != null) {
      view = AspectRatio(
        aspectRatio: aspectRatio!,
        child: view,
      );
    }

    return view;
  }
}

const String _kPreviewViewType = 'slowmo_video_recorder/preview'; 