// Commit 42: 코치 리뷰 – 영상 URL 유무에 따른 UI TDD

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/models/coach_session_item.dart';
import 'package:posture_coach/screens/coach/coach_session_review_screen.dart';

void main() {
  testWidgets('videoDownloadUrl이 없으면 안내 문구가 보인다', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: CoachSessionReviewScreen(
          item: CoachSessionItem(
            sessionId: 's1',
            userEmail: 'u@example.com',
            exerciseName: '스쿼트',
          ),
        ),
      ),
    );

    expect(find.text('업로드된 영상 URL이 없습니다.'), findsOneWidget);
  });
}
