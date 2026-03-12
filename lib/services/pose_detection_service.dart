// Commit 16: MediaPipe 연동 – 자세 감지 서비스 (어댑터 패턴)
// Commit 17: 랜드마크 추출 – 키포인트 좌표를 결과에 포함

import 'dart:typed_data';

/// 단일 키포인트 좌표 (정규화 0~1, visibility 0~1)
class LandmarkPoint {
  const LandmarkPoint({
    required this.x,
    required this.y,
    this.visibility = 1.0,
  });

  final double x;
  final double y;
  final double visibility;

  @override
  String toString() => 'Landmark(x: ${x.toStringAsFixed(3)}, y: ${y.toStringAsFixed(3)}, v: ${visibility.toStringAsFixed(2)})';
}

/// 자세 감지 결과 (공통 모델)
class PoseDetectionResult {
  const PoseDetectionResult({
    required this.hasPoses,
    required this.landmarkCount,
    this.landmarks = const [],
  });

  final bool hasPoses;
  final int landmarkCount;
  /// 추출된 랜드마크 좌표 (Commit 17). 콘솔 출력/오버레이용.
  final List<LandmarkPoint> landmarks;

  @override
  String toString() {
    if (!hasPoses) return 'PoseDetectionResult(hasPoses: false, landmarkCount: 0)';
    return 'PoseDetectionResult(hasPoses: true, landmarkCount: $landmarkCount, '
        'landmarks: ${landmarks.take(3).toString()}${landmarks.length > 3 ? '...' : ''})';
  }
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
