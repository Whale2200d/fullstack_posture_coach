// Commit 19: 표준 자세 비교 로직 – 각도 계산 기반 최소 분석기

import 'pose_angle_math.dart';
import 'pose_detection_service.dart';

class PostureAnalysisResult {
  const PostureAnalysisResult({
    required this.isValid,
    required this.angles,
    required this.issues,
  });

  final bool isValid;
  final Map<String, double> angles;
  final List<String> issues;
}

class PostureAnalyzer {
  /// 최소 분석: MediaPipe 33 랜드마크에서 무릎/등 각도를 계산한다.
  ///
  /// 현재는 Commit 19 범위로 콘솔/테스트 용도로만 사용.
  PostureAnalysisResult analyze({required List<LandmarkPoint> landmarks}) {
    if (landmarks.length < 33) {
      return const PostureAnalysisResult(
        isValid: false,
        angles: {},
        issues: ['Invalid landmarks: expected 33 points.'],
      );
    }

    final issues = <String>[];
    final angles = <String, double>{};

    // left knee: hip(23) - knee(25) - ankle(27)
    final leftKnee = PoseAngleMath.calculateAngleDegrees(
      a: landmarks[23],
      v: landmarks[25],
      c: landmarks[27],
    );
    if (leftKnee != null) {
      angles['leftKnee'] = leftKnee;
      // Dummy threshold example (to be refined later)
      if (leftKnee < 70) issues.add('Left knee too bent');
    } else {
      issues.add('Left knee angle unavailable');
    }

    // back angle (very rough): shoulderMid - hipMid - kneeMid
    final shoulderMid = _mid(landmarks[11], landmarks[12]);
    final hipMid = _mid(landmarks[23], landmarks[24]);
    final kneeMid = _mid(landmarks[25], landmarks[26]);
    final backAngle = PoseAngleMath.calculateAngleDegrees(
      a: shoulderMid,
      v: hipMid,
      c: kneeMid,
    );
    if (backAngle != null) {
      angles['back'] = backAngle;
      if (backAngle < 140) issues.add('Back too rounded');
    } else {
      issues.add('Back angle unavailable');
    }

    return PostureAnalysisResult(
      isValid: true,
      angles: angles,
      issues: issues,
    );
  }

  LandmarkPoint _mid(LandmarkPoint p1, LandmarkPoint p2) {
    return LandmarkPoint(
      x: (p1.x + p2.x) / 2,
      y: (p1.y + p2.y) / 2,
      visibility: (p1.visibility + p2.visibility) / 2,
    );
  }
}

