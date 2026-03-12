// Commit 29: 피드백 저장 후 알림 호출 TDD

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/screens/coach/coach_dashboard_screen.dart';
import 'package:posture_coach/screens/coach/coach_session_review_screen.dart';
import 'package:posture_coach/services/feedback_repository.dart';
import 'package:posture_coach/services/notification_service.dart';

class FakeFeedbackRepository implements IFeedbackRepository {
  final List<FeedbackData> saved = [];

  @override
  Future<void> saveFeedback(FeedbackData data) async {
    saved.add(data);
  }
}

class FakeNotificationService implements INotificationService {
  final List<String> messages = [];

  @override
  Future<void> sendLocal(String title, String body) async {
    messages.add('$title|$body');
  }
}

void main() {
  testWidgets('피드백 저장 후 로컬 알림이 호출된다', (tester) async {
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

    final repo = FakeFeedbackRepository();
    final notifier = FakeNotificationService();

    await tester.pumpWidget(
      MaterialApp(
        home: CoachSessionReviewScreen(
          item: item,
          feedbackRepository: repo,
          notificationService: notifier,
        ),
      ),
    );

    await tester.tap(find.text('좋아요'));
    await tester.pump();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(repo.saved.length, 1);
    expect(notifier.messages.length, 1);
    expect(notifier.messages.first, contains('피드백이 저장되었습니다'));
  });
}

