import 'dart:io';

import 'offline_upload_queue.dart';
import 'video_upload_service.dart';

class OfflineUploadRetryResult {
  OfflineUploadRetryResult({
    required this.total,
    required this.succeeded,
    required this.failed,
  });

  final int total;
  final int succeeded;
  final int failed;
}

/// 오프라인 업로드 큐에 쌓인 작업들을 다시 업로드하는 서비스.
class OfflineUploadRetryService {
  OfflineUploadRetryService({
    required IOfflineUploadQueue queue,
    required IVideoUploader uploader,
  })  : _queue = queue,
        _uploader = uploader;

  final IOfflineUploadQueue _queue;
  final IVideoUploader _uploader;

  /// Pending 상태의 작업들을 순차적으로 재시도한다.
  Future<OfflineUploadRetryResult> retryAll() async {
    final pending = await _queue.getPending();
    var succeeded = 0;
    var failed = 0;

    for (final task in pending) {
      try {
        final file = File(task.localPath);
        if (!file.existsSync()) {
          failed++;
          continue;
        }
        final now = DateTime.now().millisecondsSinceEpoch;
        final storagePath = 'videos/${task.id}_$now.mp4';
        await _uploader.uploadVideo(file: file, storagePath: storagePath);
        await _queue.markUploaded(task.id);
        succeeded++;
      } catch (_) {
        failed++;
      }
    }

    return OfflineUploadRetryResult(
      total: pending.length,
      succeeded: succeeded,
      failed: failed,
    );
  }
}

