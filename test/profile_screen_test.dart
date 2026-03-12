// Commit 21: 사용자 신체 정보 입력 폼 TDD

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/screens/profile/profile_screen.dart';
import 'package:posture_coach/services/profile_service.dart';

void main() {
  group('ProfileScreen', () {
    testWidgets('저장 버튼을 누르면 validation 에러가 표시된다', (tester) async {
      final service = ProfileService.inMemory();
      await tester.pumpWidget(
        MaterialApp(home: ProfileScreen(profileService: service)),
      );

      await tester.tap(find.text('저장'));
      await tester.pump();

      expect(find.textContaining('필수'), findsWidgets);
    });

    testWidgets('정상 입력 후 저장하면 ProfileService에 반영된다', (tester) async {
      final service = ProfileService.inMemory();
      await tester.pumpWidget(
        MaterialApp(home: ProfileScreen(profileService: service)),
      );

      await tester.enterText(find.byKey(const Key('height_cm')), '175');
      await tester.enterText(find.byKey(const Key('weight_kg')), '75');
      await tester.enterText(find.byKey(const Key('age_years')), '30');

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      final profile = service.currentProfile;
      expect(profile, isNotNull);
      expect(profile!.heightCm, 175);
      expect(profile.weightKg, 75);
      expect(profile.ageYears, 30);
    });
  });
}

