// Commit 2: Flutter 기본 위젯 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/main.dart';

void main() {
  testWidgets('앱 타이틀 표시', (WidgetTester tester) async {
    await tester.pumpWidget(const PostureCoachApp());
    expect(find.text('CrossFit Posture Coach'), findsOneWidget);
  });

  testWidgets('홈 화면 문구 표시', (WidgetTester tester) async {
    await tester.pumpWidget(const PostureCoachApp());
    expect(find.text('자세 교정 앱'), findsOneWidget);
  });
}
