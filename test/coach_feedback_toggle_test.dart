// Commit 24: 코치 피드백 입력 UI (좋아요/싫어요) TDD

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/screens/coach/coach_session_review_screen.dart';
import 'package:posture_coach/screens/coach/coach_dashboard_screen.dart';

void main() {
  testWidgets('👍/👎는 상호배타 토글이며 다시 누르면 해제된다', (tester) async {
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

    final like = find.text('좋아요');
    final dislike = find.text('싫어요');

    // initial: none selected
    expect(find.textContaining('선택: 없음'), findsOneWidget);

    // tap like -> like selected
    await tester.tap(like);
    await tester.pump();
    expect(find.textContaining('선택: 좋아요'), findsOneWidget);

    // tap dislike -> dislike selected (mutually exclusive)
    await tester.tap(dislike);
    await tester.pump();
    expect(find.textContaining('선택: 싫어요'), findsOneWidget);

    // tap dislike again -> none
    await tester.tap(dislike);
    await tester.pump();
    expect(find.textContaining('선택: 없음'), findsOneWidget);
  });
}

