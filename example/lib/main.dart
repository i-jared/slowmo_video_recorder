import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:slowmo_video_recorder/slowmo_video_recorder.dart';
import 'package:video_player/video_player.dart';
import 'package:slowmo_video_recorder/slowmo_camera_preview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _slowmoVideoRecorderPlugin = SlowmoVideoRecorder();

  // Indicates whether a recording session is currently active.
  bool _isRecording = false;

  // Holds the absolute file path returned by the last successful recording.
  String? _lastVideoPath;

  // Human-readable status displayed in the UI.
  String _status = 'Idle';

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _slowmoVideoRecorderPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  /// Starts a new slow-motion recording using the plugin.
  Future<void> _startRecording() async {
    setState(() {
      _status = 'Starting recording…';
    });

    try {
      await _slowmoVideoRecorderPlugin.startRecording();
      setState(() {
        _isRecording = true;
        _status = 'Recording…';
      });
    } catch (e) {
      setState(() {
        _status = 'Error starting recording: $e';
      });
    }
  }

  /// Stops the active recording and stores the resulting file path.
  Future<void> _stopRecording() async {
    setState(() {
      _status = 'Stopping recording…';
    });

    try {
      final path = await _slowmoVideoRecorderPlugin.stopRecording();
      setState(() {
        _isRecording = false;
        _lastVideoPath = path;
        _status = path != null ? 'Saved to: $path' : 'Recording cancelled.';
      });

      if (path != null) {
        await _setupVideoPlayer(path);
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _status = 'Error stopping recording: $e';
      });
    }
  }

  Future<void> _setupVideoPlayer(String filePath) async {
    // Dispose previous controller if any.
    await _videoController?.dispose();

    final controller = VideoPlayerController.file(File(filePath));
    _videoController = controller;

    await controller.setLooping(true);
    await controller.initialize();
    // Play at quarter speed if recorded at 120 fps so output is ~30 fps.
    await controller.setPlaybackSpeed(0.25);

    setState(() {}); // Refresh UI once initialized.

    await controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Running on!: $_platformVersion',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_lastVideoPath != null) ...[
                const SizedBox(height: 8),
                Text(
                  _lastVideoPath!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 16),

              // Either show the live preview or the last recorded video.
              Expanded(
                child: _videoController != null && _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      )
                    : const SlowmoCameraPreview(aspectRatio: 9 / 16),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
                    label: Text(_isRecording ? 'Stop' : 'Record'),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    onPressed: _reset,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Resets the UI back to its original state, disposing of any loaded video.
  Future<void> _reset() async {
    await _videoController?.dispose();
    setState(() {
      _videoController = null;
      _lastVideoPath = null;
      _status = 'Idle';
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}
