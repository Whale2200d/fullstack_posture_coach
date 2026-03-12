// Commit 18: 화면 오버레이 (오류 선 그리기) TDD
//
// 검증: 랜드마크가 없을 때도 위젯이 빌드되고, 랜드마크가 있으면 CustomPaint로 빨간 선을 그린다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/services/pose_detection_service.dart';
import 'package:posture_coach/widgets/pose_skeleton_overlay.dart';

void main() {
  group('PoseSkeletonOverlay', () {
    testWidgets('랜드마크가 없어도 위젯이 빌드된다', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoseSkeletonOverlay(
              landmarks: const [],
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      expect(find.byType(PoseSkeletonOverlay), findsOneWidget);
    });

    testWidgets('랜드마크가 있으면 CustomPaint가 그려진다', (WidgetTester tester) async {
      final landmarks = List.generate(
        33,
        (i) => LandmarkPoint(
          x: 0.5 + (i % 5) * 0.05,
          y: 0.2 + (i ~/ 5) * 0.1,
          visibility: 0.9,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoseSkeletonOverlay(
              landmarks: landmarks,
              child: const SizedBox(width: 200, height: 200),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(PoseSkeletonOverlay),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });
  });
}
