// Commit 16: MediaPipe 실기기 연동 – NpuPoseDetector 래퍼

import 'dart:typed_data';

import 'package:flutter_pose_detection/flutter_pose_detection.dart';

import 'pose_detection_service.dart';

/// flutter_pose_detection(NpuPoseDetector) 기반 실기기용 어댑터
class MediaPipePoseDetectorAdapter implements IPoseDetector {
  MediaPipePoseDetectorAdapter() : _detector = NpuPoseDetector();

  final NpuPoseDetector _detector;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    await _detector.initialize();
    _initialized = true;
  }

  @override
  Future<PoseDetectionResult> detect(Uint8List imageBytes) async {
    if (!_initialized) {
      throw StateError(
        'MediaPipePoseDetectorAdapter.initialize() must be called first.',
      );
    }
    final result = await _detector.detectPose(imageBytes);
    final landmarkCount = result.hasPoses && result.firstPose != null
        ? result.firstPose!.landmarks.length
        : 0;
    return PoseDetectionResult(
      hasPoses: result.hasPoses,
      landmarkCount: landmarkCount,
    );
  }

  /// 리소스 해제 (화면 종료 시 호출 권장)
  void dispose() {
    _detector.dispose();
  }
}
