import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/services/offline_upload_queue.dart';
import 'package:posture_coach/services/offline_upload_retry_service.dart';
import 'package:posture_coach/services/video_upload_service.dart';

class RecordingVideoUploader implements IVideoUploader {
  final List<String> storagePaths = [];

  @override
  Future<String> uploadVideo({
    required File file,
    required String storagePath,
  }) async {
    storagePaths.add(storagePath);
    return 'https://example.com/$storagePath';
  }
}

void main() {
  group('OfflineUploadRetryService', () {
    test('pending 작업들을 재시도 후 성공하면 큐에서 markUploaded 된다', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final file1 = File('${tempDir.path}/video1.mp4')
        ..writeAsBytesSync([0, 1, 2]);
      final file2 = File('${tempDir.path}/video2.mp4')
        ..writeAsBytesSync([3, 4, 5]);

      final queue = MemoryOfflineUploadQueue();
      await queue.enqueue(file1.path);
      await queue.enqueue(file2.path);

      final uploader = RecordingVideoUploader();
      final service = OfflineUploadRetryService(queue: queue, uploader: uploader);

      final result = await service.retryAll();

      expect(result.total, 2);
      expect(result.succeeded, 2);
      expect(result.failed, 0);
      expect(uploader.storagePaths.length, 2);

      final pendingAfter = await queue.getPending();
      expect(pendingAfter, isEmpty);
    });

    test('존재하지 않는 파일은 실패로 집계되고 큐에 남는다', () async {
      final queue = MemoryOfflineUploadQueue();
      await queue.enqueue('/path/not_exist.mp4');

      final uploader = RecordingVideoUploader();
      final service = OfflineUploadRetryService(queue: queue, uploader: uploader);

      final result = await service.retryAll();

      expect(result.total, 1);
      expect(result.succeeded, 0);
      expect(result.failed, 1);

      final pendingAfter = await queue.getPending();
      expect(pendingAfter.length, 1);
    });
  });
}

