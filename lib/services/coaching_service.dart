// Commit 20: 자동 코칭 텍스트/음성 피드백

import 'posture_analyzer.dart';

class CoachingResult {
  const CoachingResult({required this.messages});

  final List<String> messages;

  String get ttsText => messages.join('. ');
}

abstract class ITtsEngine {
  Future<void> speak(String text);
}

class CoachingService {
  CoachingService({ITtsEngine? tts}) : _tts = tts;

  final ITtsEngine? _tts;

  CoachingResult buildCoaching(PostureAnalysisResult analysis) {
    if (!analysis.isValid) {
      return const CoachingResult(messages: ['자세를 인식하지 못했어요. 다시 촬영해 주세요.']);
    }

    final messages = <String>[];
    for (final issue in analysis.issues) {
      switch (issue) {
        case 'Left knee too bent':
          messages.add('무릎이 너무 많이 굽혀졌어요. 무릎 각도를 조금 펴보세요');
          break;
        case 'Back too rounded':
          messages.add('등이 말렸어요. 가슴을 열고 등을 펴보세요');
          break;
        case 'Left knee angle unavailable':
          messages.add('무릎이 잘 보이도록 카메라 위치를 조정해 주세요');
          break;
        case 'Back angle unavailable':
          messages.add('상체가 잘 보이도록 카메라 각도를 조정해 주세요');
          break;
        default:
          // Unknown issues are ignored for now
          break;
      }
    }

    if (messages.isEmpty) {
      messages.add('좋아요! 자세가 안정적이에요');
    }

    return CoachingResult(messages: messages);
  }

  Future<void> speak(CoachingResult coaching) async {
    final tts = _tts;
    if (tts == null) return;
    if (coaching.messages.isEmpty) return;
    await tts.speak(coaching.ttsText);
  }
}

