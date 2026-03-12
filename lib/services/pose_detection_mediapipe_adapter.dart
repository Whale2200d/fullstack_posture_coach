// Commit 16: MediaPipe 실기기 연동 – NpuPoseDetector 래퍼
// Commit 17: 랜드마크 추출 – LandmarkPoint 리스트 반환

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
    if (!result.hasPoses || result.firstPose == null) {
      return const PoseDetectionResult(
        hasPoses: false,
        landmarkCount: 0,
        landmarks: [],
      );
    }
    final pose = result.firstPose!;
    final landmarks = pose.landmarks
        .map((l) => LandmarkPoint(
              x: l.x,
              y: l.y,
              visibility: l.visibility,
            ))
        .toList();
    return PoseDetectionResult(
      hasPoses: true,
      landmarkCount: landmarks.length,
      landmarks: landmarks,
    );
  }

  /// 리소스 해제 (화면 종료 시 호출 권장)
  void dispose() {
    _detector.dispose();
  }
}
