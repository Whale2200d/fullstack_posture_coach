// Posture Coach - 카메라 화면
// Commit 14: camera 플러그인으로 기본 프리뷰/녹화 구현

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'video_preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeFuture;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이 기기에서 사용 가능한 카메라를 찾을 수 없습니다.'),
          ),
        );
        return;
      }

      // 후면 카메라 우선, 없으면 첫 번째 카메라 사용
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
      );
      _initializeFuture = controller.initialize();
      setState(() {
        _controller = controller;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카메라 초기화 실패: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      if (_isRecording) {
        final file = await controller.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });
        if (!mounted) return;

        // 앱 전용 디렉터리로 파일 이동 후 미리보기 화면으로 전환
        final appDir = await getApplicationDocumentsDirectory();
        final destPath =
            '${appDir.path}/videos/${DateTime.now().millisecondsSinceEpoch}.mp4';
        final destFile = await File(destPath).create(recursive: true);
        await File(file.path).copy(destFile.path);

        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VideoPreviewScreen(file: destFile),
          ),
        );
      } else {
        await controller.prepareForVideoRecording();
        await controller.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('녹화 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 모바일(iOS/Android) 이외 플랫폼에서는 카메라 플러그인을 사용하지 않고 안내만 표시.
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);

    if (!isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('촬영'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '카메라 기능은 현재 iOS/Android 모바일에서 우선 지원됩니다.\n'
              '웹/macOS에서는 추후 미디어 업로드 방식으로 지원할 예정입니다.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('촬영'),
      ),
      body: controller == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: _initializeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CameraPreview(controller),
                    ),
                    // 향후 자세 오버레이용 레이어
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.all(16),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(
                                '프레임 안에 전신이 보이도록 서 주세요.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: _toggleRecord,
              backgroundColor:
                  _isRecording ? Colors.red : Theme.of(context).primaryColor,
              child: Icon(_isRecording ? Icons.stop : Icons.videocam),
            ),
          ],
        ),
      ),
    );
  }
}


