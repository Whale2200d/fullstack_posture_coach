// Commit 20: 자동 코칭 텍스트/음성 피드백 TDD

import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/services/coaching_service.dart';
import 'package:posture_coach/services/posture_analyzer.dart';

class FakeTtsEngine implements ITtsEngine {
  final List<String> spoken = [];

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
  }
}

void main() {
  group('CoachingService', () {
    test('issues를 코칭 메시지로 매핑한다', () {
      const analysis = PostureAnalysisResult(
        isValid: true,
        angles: {'leftKnee': 60},
        issues: ['Left knee too bent', 'Back too rounded'],
      );

      final coaching = CoachingService().buildCoaching(analysis);

      expect(coaching.messages, isNotEmpty);
      expect(coaching.messages.join(' '), contains('무릎'));
      expect(coaching.messages.join(' '), contains('등'));
    });

    test('TTS가 켜져 있으면 speak가 호출된다', () async {
      const analysis = PostureAnalysisResult(
        isValid: true,
        angles: {'leftKnee': 60},
        issues: ['Left knee too bent'],
      );

      final fakeTts = FakeTtsEngine();
      final service = CoachingService(tts: fakeTts);
      final coaching = service.buildCoaching(analysis);

      await service.speak(coaching);

      expect(fakeTts.spoken.length, 1);
      expect(fakeTts.spoken.first, contains('무릎'));
    });
  });
}

