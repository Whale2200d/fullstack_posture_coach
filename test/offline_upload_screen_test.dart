import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/screens/offline_upload_screen.dart';
import 'package:posture_coach/services/offline_upload_queue.dart';
import 'package:posture_coach/services/offline_upload_retry_service.dart';
import 'package:posture_coach/services/video_upload_service.dart';

class FakeQueue implements IOfflineUploadQueue {
  FakeQueue(this._tasks);

  final List<OfflineUploadTask> _tasks;

  @override
  Future<void> enqueue(String localPath) async {}

  @override
  Future<List<OfflineUploadTask>> getPending() async {
    return _tasks;
  }

  @override
  Future<void> markUploaded(String id) async {}
}

class FakeUploader implements IVideoUploader {
  int callCount = 0;

  @override
  Future<String> uploadVideo({
    required File file,
    required String storagePath,
  }) async {
    callCount++;
    return 'ok';
  }
}

void main() {
  testWidgets('대기 중인 작업이 없을 때 안내 문구가 보인다', (tester) async {
    final queue = FakeQueue([]);
    final uploader = FakeUploader();

    await tester.pumpWidget(
      MaterialApp(
        home: OfflineUploadScreen(
          queue: queue,
          uploader: uploader,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('대기 중인 오프라인 업로드 작업이 없습니다.'),
      findsOneWidget,
    );
  });
}

