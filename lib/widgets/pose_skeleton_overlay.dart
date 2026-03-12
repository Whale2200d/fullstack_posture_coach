// Commit 18: 화면 오버레이 – 랜드마크 기반 빨간 선(오류 선) 그리기
//
// Canvas/CustomPaint로 스켈레톤 연결선을 그려 시각적 확인용.

import 'package:flutter/material.dart';

import '../services/pose_detection_service.dart';

/// MediaPipe 33 랜드마크 인덱스 기준 스켈레톤 연결 (오른팔·오른다리 등)
const List<({int a, int b})> _skeletonConnections = [
  (a: 7, b: 2),
  (a: 2, b: 0),
  (a: 0, b: 5),
  (a: 5, b: 8),
  (a: 11, b: 12),
  (a: 11, b: 23),
  (a: 12, b: 24),
  (a: 23, b: 24),
  (a: 11, b: 13),
  (a: 13, b: 15),
  (a: 12, b: 14),
  (a: 14, b: 16),
  (a: 23, b: 25),
  (a: 25, b: 27),
  (a: 27, b: 29),
  (a: 24, b: 26),
  (a: 26, b: 28),
  (a: 28, b: 30),
];

/// 랜드마크를 잇는 빨간 선을 그리는 CustomPainter
class PoseSkeletonPainter extends CustomPainter {
  PoseSkeletonPainter({
    required this.landmarks,
    this.minVisibility = 0.3,
    this.lineColor = Colors.red,
    this.strokeWidth = 3.0,
  });

  final List<LandmarkPoint> landmarks;
  final double minVisibility;
  final Color lineColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.length < 33) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (final conn in _skeletonConnections) {
      if (conn.a >= landmarks.length || conn.b >= landmarks.length) continue;
      final p1 = landmarks[conn.a];
      final p2 = landmarks[conn.b];
      if (p1.visibility < minVisibility || p2.visibility < minVisibility) continue;

      final offset1 = Offset(p1.x * size.width, p1.y * size.height);
      final offset2 = Offset(p2.x * size.width, p2.y * size.height);
      canvas.drawLine(offset1, offset2, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PoseSkeletonPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// 자식 위에 랜드마크 스켈레톤(빨간 선)을 그리는 오버레이 위젯
class PoseSkeletonOverlay extends StatelessWidget {
  const PoseSkeletonOverlay({
    super.key,
    required this.landmarks,
    required this.child,
    this.minVisibility = 0.3,
    this.lineColor = Colors.red,
  });

  final List<LandmarkPoint> landmarks;
  final Widget child;
  final double minVisibility;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (landmarks.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return CustomPaint(
                size: size,
                painter: PoseSkeletonPainter(
                  landmarks: landmarks,
                  minVisibility: minVisibility,
                  lineColor: lineColor,
                ),
              );
            },
          ),
      ],
    );
  }
}
