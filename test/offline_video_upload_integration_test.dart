import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/screens/video_preview_screen.dart';
import 'package:posture_coach/services/offline_upload_queue.dart';
import 'package:posture_coach/services/video_upload_service.dart';

class ThrowingVideoUploader implements IVideoUploader {
  @override
  Future<String> uploadVideo({
    required File file,
    required String storagePath,
  }) async {
    throw Exception('network error');
  }
}

void main() {
  testWidgets(
    '업로드 실패 시 오프라인 업로드 큐에 작업이 저장된다',
    (tester) async {
      final tempDir = Directory.systemTemp.createTempSync();
      final file = File('${tempDir.path}/sample_offline.mp4')
        ..writeAsBytesSync([0, 1, 2, 3]);

      final uploader = ThrowingVideoUploader();
      final queue = MemoryOfflineUploadQueue();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return VideoPreviewScreen(
                  file: file,
                  uploader: uploader,
                  offlineQueue: queue,
                );
              },
            ),
          ),
        ),
      );

      // 비디오 초기화 FutureBuilder가 완료될 때까지 진행
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.tap(find.text('업로드'));
      await tester.pumpAndSettle();

      final pending = await queue.getPending();
      expect(pending.length, 1);
      expect(pending.first.localPath, file.path);

      // 사용자에게 오프라인 큐 저장 안내가 표시된다.
      expect(
        find.textContaining('오프라인 업로드 큐에 저장되었습니다'),
        findsOneWidget,
      );
    },
  );
}

