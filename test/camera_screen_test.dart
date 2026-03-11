// Commit 15: CameraScreen 테스트
//
// 목표:
// - 데스크톱/웹과 같이 모바일이 아닌 플랫폼에서는
//   camera 플러그인을 호출하지 않고 안내 텍스트만 표시하는지 검증.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/screens/camera_screen.dart';

void main() {
  testWidgets(
    '모바일이 아닌 플랫폼에서는 안내 텍스트만 표시한다',
    (WidgetTester tester) async {
      // 테스트 환경에서 기본 플랫폼(보통 TargetPlatform.android)을
      // macOS로 덮어써서 "비모바일" 환경을 시뮬레이션한다.
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await tester.pumpWidget(
        const MaterialApp(
          home: CameraScreen(),
        ),
      );

      // 안내 문구가 보이는지 확인.
      expect(
        find.textContaining('카메라 기능은 현재 iOS/Android 모바일에서 우선 지원됩니다'),
        findsOneWidget,
      );

      // CameraPreview 대신 일반 텍스트만 있어야 하므로 FAB(녹화 버튼)도 없어야 한다.
      expect(find.byType(FloatingActionButton), findsNothing);

      // 플랫폼 오버라이드를 원래 상태로 되돌린다.
      debugDefaultTargetPlatformOverride = null;
    },
  );
}

