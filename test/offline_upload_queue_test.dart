// Commit 30: 오프라인 업로드 큐 TDD (서비스 레벨)

import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/services/offline_upload_queue.dart';

void main() {
  group('MemoryOfflineUploadQueue', () {
    test('enqueue 후 pending 목록에 쌓이고 markUploaded로 제거된다', () async {
      final queue = MemoryOfflineUploadQueue();

      await queue.enqueue('/path/video1.mp4');
      await queue.enqueue('/path/video2.mp4');

      var pending = await queue.getPending();
      expect(pending.length, 2);
      expect(pending[0].localPath, '/path/video1.mp4');

      await queue.markUploaded(pending[0].id);

      pending = await queue.getPending();
      expect(pending.length, 1);
      expect(pending[0].localPath, '/path/video2.mp4');
    });
  });
}

