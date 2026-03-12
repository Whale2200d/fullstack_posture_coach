// Commit 20: TTS 구현체 (flutter_tts)

import 'package:flutter_tts/flutter_tts.dart';

import 'coaching_service.dart';

class FlutterTtsEngine implements ITtsEngine {
  FlutterTtsEngine({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> speak(String text) async {
    // Minimal default settings (can be expanded later)
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }
}

