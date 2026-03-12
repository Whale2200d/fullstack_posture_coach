// Commit 16: MediaPipe 연동 TDD – PoseDetectionService 테스트
//
// 검증: 어댑터를 주입했을 때, detect 결과가 그대로 반환된다.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/services/pose_detection_service.dart';

/// 테스트용 Fake: 네이티브 MediaPipe 없이 결과만 반환
class FakePoseDetectorAdapter implements IPoseDetector {
  FakePoseDetectorAdapter({this.hasPoses = false, this.landmarkCount = 0});

  final bool hasPoses;
  final int landmarkCount;

  @override
  Future<void> initialize() async {}

  @override
  Future<PoseDetectionResult> detect(Uint8List imageBytes) async {
    return PoseDetectionResult(
      hasPoses: hasPoses,
      landmarkCount: landmarkCount,
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
  });
}
