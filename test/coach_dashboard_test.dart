// Commit 23: 코치 대시보드 기본 UI (Flutter Web) TDD

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/models/coach_session_item.dart';
import 'package:posture_coach/screens/coach/coach_dashboard_screen.dart';

void main() {
  testWidgets('더미 세션 목록이 리스트로 표시된다', (tester) async {
    final sessions = [
      const CoachSessionItem(
        sessionId: 's1',
        userEmail: 'user1@example.com',
        exerciseName: '스쿼트',
      ),
      const CoachSessionItem(
        sessionId: 's2',
        userEmail: 'user2@example.com',
        exerciseName: '데드리프트',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: CoachDashboardScreen(items: sessions),
      ),
    );

    expect(find.text('코치 대시보드'), findsOneWidget);
    expect(find.textContaining('user1@example.com'), findsOneWidget);
    expect(find.textContaining('스쿼트'), findsOneWidget);
    expect(find.textContaining('user2@example.com'), findsOneWidget);
    expect(find.textContaining('데드리프트'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });
}

