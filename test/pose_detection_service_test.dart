// Commit 16: MediaPipe 연동 TDD – PoseDetectionService 테스트
// Commit 17: 랜드마크 추출 – 샘플 이미지 입력 시 landmarks 반환 검증

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/services/pose_detection_service.dart';

/// 테스트용 Fake: 네이티브 MediaPipe 없이 결과만 반환
class FakePoseDetectorAdapter implements IPoseDetector {
  FakePoseDetectorAdapter({
    this.hasPoses = false,
    this.landmarkCount = 0,
    this.landmarks = const [],
  });

  final bool hasPoses;
  final int landmarkCount;
  final List<LandmarkPoint> landmarks;

  @override
  Future<void> initialize() async {}

  @override
  Future<PoseDetectionResult> detect(Uint8List imageBytes) async {
    return PoseDetectionResult(
      hasPoses: hasPoses,
      landmarkCount: landmarkCount,
      landmarks: landmarks,
    );
  }
}

void main() {
  group('PoseDetectionService', () {
    test('Fake 어댑터로 초기화 후 detect 시 hasPoses false 이다', () async {
      final service = PoseDetectionService(
        adapter: FakePoseDetectorAdapter(),
      );
      await service.initialize();

      final result = await service.detect(Uint8List(0));

      expect(result.hasPoses, isFalse);
      expect(result.landmarkCount, 0);
      expect(result.landmarks, isEmpty);
    });

    test('Fake 어댑터에서 hasPoses true 를 주면 detect 결과가 true 이다', () async {
      final service = PoseDetectionService(
        adapter: FakePoseDetectorAdapter(hasPoses: true, landmarkCount: 33),
      );
      await service.initialize();

      final result = await service.detect(Uint8List(100));

      expect(result.hasPoses, isTrue);
      expect(result.landmarkCount, 33);
    });

    test('샘플 이미지 입력 시 랜드마크 좌표가 추출되어 반환된다', () async {
      final sampleLandmarks = [
        const LandmarkPoint(x: 0.1, y: 0.2, visibility: 0.9),
        const LandmarkPoint(x: 0.3, y: 0.4, visibility: 0.8),
      ];
      final service = PoseDetectionService(
        adapter: FakePoseDetectorAdapter(
          hasPoses: true,
          landmarkCount: 2,
          landmarks: sampleLandmarks,
        ),
      );
      await service.initialize();

      final sampleImageBytes = Uint8List(256);
      final result = await service.detect(sampleImageBytes);

      expect(result.hasPoses, isTrue);
      expect(result.landmarkCount, 2);
      expect(result.landmarks.length, 2);
      expect(result.landmarks[0].x, 0.1);
      expect(result.landmarks[0].y, 0.2);
      expect(result.landmarks[0].visibility, 0.9);
      expect(result.landmarks[1].x, 0.3);
      expect(result.landmarks[1].y, 0.4);
    });
  });
}
