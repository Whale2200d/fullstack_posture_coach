// Commit 22: 촬영 영상 업로드 (Firebase Storage) – 서비스 인터페이스

import 'dart:io';

abstract class IVideoUploader {
  /// Uploads [file] to [storagePath] and returns a download URL.
  Future<String> uploadVideo({
    required File file,
    required String storagePath,
  });
}

