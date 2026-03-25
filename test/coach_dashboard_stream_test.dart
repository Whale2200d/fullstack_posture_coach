// Commit 41: 세션 목록 스트림으로 코치 대시보드 표시 TDD

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/models/coach_session_item.dart';
import 'package:posture_coach/screens/coach/coach_dashboard_screen.dart';
import 'package:posture_coach/services/session_list_repository.dart';

class FakeSessionListRepository implements ISessionListRepository {
  FakeSessionListRepository(this._controller);

  final StreamController<List<CoachSessionItem>> _controller;

  @override
  Stream<List<CoachSessionItem>> watchRecentSessions({int limit = 50}) {
    return _controller.stream;
  }
}

void main() {
  testWidgets('sessionListRepository 스트림이 리스트에 반영된다', (tester) async {
    final controller = StreamController<List<CoachSessionItem>>();
    final repo = FakeSessionListRepository(controller);

    await tester.pumpWidget(
      MaterialApp(
        home: CoachDashboardScreen(sessionListRepository: repo),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.add([
      const CoachSessionItem(
        sessionId: 's1',
        userEmail: 'stream@example.com',
        exerciseName: '스쿼트',
      ),
    ]);
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('stream@example.com'), findsOneWidget);
    expect(find.textContaining('스쿼트'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await controller.close();
  });
}
