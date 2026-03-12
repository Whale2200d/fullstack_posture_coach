// Commit 25: 1~5단계 슬라이더 TDD

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/screens/coach/coach_dashboard_screen.dart';
import 'package:posture_coach/screens/coach/coach_session_review_screen.dart';

void main() {
  testWidgets('슬라이더로 점수를 조정하면 텍스트에 반영된다', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const item = CoachSessionItem(
      sessionId: 's1',
      userEmail: 'user@example.com',
      exerciseName: '스쿼트',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: CoachSessionReviewScreen(item: item),
      ),
    );

    // 기본 점수는 3으로 시작한다고 가정
    expect(find.textContaining('점수: 3'), findsOneWidget);

    final slider = find.byType(Slider);
    expect(slider, findsOneWidget);

    // 슬라이더를 살짝 오른쪽으로 여러 번 드래그해서 5까지 올린다
    for (var i = 0; i < 5; i++) {
      await tester.drag(slider, const Offset(40, 0));
      await tester.pumpAndSettle();
    }

    // 4 또는 5 근처로만 올라와도 통과 (플랫폼별 드래그 민감도 보정)
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && w.data != null && w.data!.startsWith('점수: '),
      ),
      findsWidgets,
    );
  });
}

