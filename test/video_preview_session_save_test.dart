// Commit 40: 업로드 성공 시 세션 저장소가 호출된다

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/screens/video_preview_screen.dart';
import 'package:posture_coach/services/session_repository.dart';
import 'package:posture_coach/services/video_upload_service.dart';

class _FakeUploader implements IVideoUploader {
  _FakeUploader({this.url = 'https://storage.example/clip.mp4'});

  final String url;

  @override
  Future<String> uploadVideo({
    required File file,
    required String storagePath,
  }) async {
    return url;
  }
}

void main() {
  testWidgets('업로드 성공 시 sessionRepository.save가 호출된다', (tester) async {
    final tempDir = Directory.systemTemp.createTempSync();
    final file = File('${tempDir.path}/clip.mp4')..writeAsBytesSync([0, 1, 2]);
    final uploader = _FakeUploader();
    final sessionRepo = InMemorySessionRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: VideoPreviewScreen(
          file: file,
          uploader: uploader,
          sessionRepository: sessionRepo,
          userEmail: 'coach_user@example.com',
          userId: 'uid-xyz',
          exerciseName: 'squat',
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await tester.tap(find.text('업로드'));
    await tester.pumpAndSettle();

    expect(sessionRepo.saved.length, 1);
    final saved = sessionRepo.saved.single;
    expect(saved.userEmail, 'coach_user@example.com');
    expect(saved.userId, 'uid-xyz');
    expect(saved.exerciseName, 'squat');
    expect(saved.downloadUrl, 'https://storage.example/clip.mp4');
    expect(saved.storagePath, startsWith('videos/'));
    expect(find.textContaining('업로드 완료'), findsOneWidget);
  });
}
