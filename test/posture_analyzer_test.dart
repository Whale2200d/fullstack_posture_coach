// Commit 19: 표준 자세 비교 로직 (각도 계산) – 분석기 TDD

import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/services/posture_analyzer.dart';
import 'package:posture_coach/services/pose_detection_service.dart';

void main() {
  group('PostureAnalyzer', () {
    test('랜드마크가 33개 미만이면 분석 불가로 나온다', () {
      final analyzer = PostureAnalyzer();
      final result = analyzer.analyze(landmarks: const []);

      expect(result.isValid, isFalse);
      expect(result.angles, isEmpty);
      expect(result.issues, isNotEmpty);
    });

    test('무릎 각도를 계산한다 (직각 ≈ 90도)', () {
      // leftHip(23), leftKnee(25), leftAnkle(27)
      // hip = (0,0), knee=(1,0), ankle=(1,1) => angle at knee is 90
      final landmarks = List<LandmarkPoint>.generate(
        33,
        (_) => const LandmarkPoint(x: 0, y: 0, visibility: 0.0),
      );
      landmarks[23] = const LandmarkPoint(x: 0, y: 0, visibility: 0.9);
      landmarks[25] = const LandmarkPoint(x: 1, y: 0, visibility: 0.9);
      landmarks[27] = const LandmarkPoint(x: 1, y: 1, visibility: 0.9);

      final analyzer = PostureAnalyzer();
      final result = analyzer.analyze(landmarks: landmarks);

      expect(result.isValid, isTrue);
      expect(result.angles['leftKnee'], isNotNull);
      expect(result.angles['leftKnee']!, closeTo(90.0, 1e-6));
    });
  });
}

