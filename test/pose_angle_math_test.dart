// Commit 19: 표준 자세 비교 로직 (각도 계산) TDD

import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/services/pose_angle_math.dart';
import 'package:posture_coach/services/pose_detection_service.dart';

void main() {
  group('PoseAngleMath.calculateAngleDegrees', () {
    test('직각(90도)을 계산한다', () {
      // vertex at (0,0), points at (1,0) and (0,1)
      final a = const LandmarkPoint(x: 1, y: 0);
      final v = const LandmarkPoint(x: 0, y: 0);
      final c = const LandmarkPoint(x: 0, y: 1);

      final angle = PoseAngleMath.calculateAngleDegrees(a: a, v: v, c: c);

      expect(angle, isNotNull);
      expect(angle!, closeTo(90.0, 1e-6));
    });

    test('일직선(180도)을 계산한다', () {
      // a -> v -> c is straight line
      final a = const LandmarkPoint(x: -1, y: 0);
      final v = const LandmarkPoint(x: 0, y: 0);
      final c = const LandmarkPoint(x: 1, y: 0);

      final angle = PoseAngleMath.calculateAngleDegrees(a: a, v: v, c: c);

      expect(angle, isNotNull);
      expect(angle!, closeTo(180.0, 1e-6));
    });

    test('점이 겹치면 null 을 반환한다', () {
      final a = const LandmarkPoint(x: 0, y: 0);
      final v = const LandmarkPoint(x: 0, y: 0);
      final c = const LandmarkPoint(x: 1, y: 0);

      final angle = PoseAngleMath.calculateAngleDegrees(a: a, v: v, c: c);

      expect(angle, isNull);
    });
  });
}

