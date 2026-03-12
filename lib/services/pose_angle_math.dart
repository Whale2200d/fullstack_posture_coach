// Commit 19: 표준 자세 비교 로직 – 각도 계산 (벡터 수학)

import 'dart:math' as math;

import 'pose_detection_service.dart';

class PoseAngleMath {
  /// Returns angle in degrees at vertex v for points a-v-c.
  ///
  /// Returns null if vectors have zero length.
  static double? calculateAngleDegrees({
    required LandmarkPoint a,
    required LandmarkPoint v,
    required LandmarkPoint c,
  }) {
    final v1x = a.x - v.x;
    final v1y = a.y - v.y;
    final v2x = c.x - v.x;
    final v2y = c.y - v.y;

    final mag1 = math.sqrt(v1x * v1x + v1y * v1y);
    final mag2 = math.sqrt(v2x * v2x + v2y * v2y);
    if (mag1 == 0 || mag2 == 0) return null;

    final dot = v1x * v2x + v1y * v2y;
    final cos = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
    return math.acos(cos) * 180 / math.pi;
  }
}

