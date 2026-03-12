// Commit 22: Firebase Storage 업로드 TDD (Fake로 검증)

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/screens/video_preview_screen.dart';
import 'package:posture_coach/services/video_upload_service.dart';

class FakeVideoUploader implements IVideoUploader {
  FakeVideoUploader({this.url = 'https://example.com/video.mp4'});

  final String url;
  int callCount = 0;

  @override
  Future<String> uploadVideo({
    required File file,
    required String storagePath,
  }) async {
    callCount++;
    return url;
  }
}

void main() {
  testWidgets('업로드 버튼을 누르면 uploader가 호출되고 URL이 표시된다', (tester) async {
    final tempDir = Directory.systemTemp.createTempSync();
    final file = File('${tempDir.path}/sample.mp4')..writeAsBytesSync([0, 1, 2, 3]);
    final uploader = FakeVideoUploader();

    await tester.pumpWidget(
      MaterialApp(
        home: VideoPreviewScreen(
          file: file,
          uploader: uploader,
        ),
      ),
    );

    // 비디오 초기화 FutureBuilder가 완료될 때까지 진행
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    await tester.tap(find.text('업로드'));
    await tester.pumpAndSettle();

    expect(uploader.callCount, 1);
    expect(find.textContaining('업로드 완료'), findsOneWidget);
    expect(find.textContaining('https://example.com/video.mp4'), findsOneWidget);
  });
}

