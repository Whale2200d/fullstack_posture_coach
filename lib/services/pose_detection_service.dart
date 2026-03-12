// Commit 16: MediaPipe 연동 – 자세 감지 서비스 (어댑터 패턴)
//
// 테스트에서는 FakePoseDetectorAdapter 를 주입해 네이티브 의존 없이 검증.

import 'dart:typed_data';

/// 자세 감지 결과 (공통 모델)
class PoseDetectionResult {
  const PoseDetectionResult({
    required this.hasPoses,
    required this.landmarkCount,
  });

  final bool hasPoses;
  final int landmarkCount;
}

/// 자세 감지 구현체 주입용 인터페이스 (실기기: MediaPipe, 테스트: Fake)
abstract class IPoseDetector {
  Future<void> initialize();
  Future<PoseDetectionResult> detect(Uint8List imageBytes);
}

/// 서비스: 초기화 및 이미지 바이트로 자세 감지
class PoseDetectionService {
  PoseDetectionService({required IPoseDetector adapter}) : _adapter = adapter;

  final IPoseDetector _adapter;
  bool _initialized = false;

  Future<void> initialize() async {
    await _adapter.initialize();
    _initialized = true;
  }

  Future<PoseDetectionResult> detect(Uint8List imageBytes) async {
    if (!_initialized) {
      throw StateError('PoseDetectionService.initialize() must be called first.');
    }
    return _adapter.detect(imageBytes);
  }
}
