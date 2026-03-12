// Commit 26: 피드백 데이터 Firestore 저장 – TDD (Fake Repository)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/screens/coach/coach_dashboard_screen.dart';
import 'package:posture_coach/screens/coach/coach_session_review_screen.dart';
import 'package:posture_coach/services/feedback_repository.dart';

class FakeFeedbackRepository implements IFeedbackRepository {
  final List<FeedbackData> saved = [];

  @override
  Future<void> saveFeedback(FeedbackData data) async {
    saved.add(data);
  }
}

void main() {
  testWidgets('저장 버튼을 누르면 피드백(세션ID, 좋아요/싫어요, 점수)이 저장된다', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const item = CoachSessionItem(
      sessionId: 'session_001',
      userEmail: 'user@example.com',
      exerciseName: '스쿼트',
    );

    final repo = FakeFeedbackRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: CoachSessionReviewScreen(
          item: item,
          feedbackRepository: repo,
        ),
      ),
    );

    // 좋아요 선택 후 저장
    await tester.tap(find.text('좋아요'));
    await tester.pump();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(repo.saved.length, 1);
    final data = repo.saved.first;
    expect(data.sessionId, 'session_001');
    expect(data.userEmail, 'user@example.com');
    expect(data.exerciseName, '스쿼트');
    expect(data.isPositive, isTrue);
    expect(data.score >= 1 && data.score <= 5, isTrue);
  });
}

