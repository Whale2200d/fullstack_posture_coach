// Commit 22: Firebase Storage 업로더 구현

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'video_upload_service.dart';

class FirebaseStorageVideoUploader implements IVideoUploader {
  FirebaseStorageVideoUploader({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<String> uploadVideo({
    required File file,
    required String storagePath,
  }) async {
    final ref = _storage.ref().child(storagePath);
    final task = ref.putFile(
      file,
      SettableMetadata(contentType: 'video/mp4'),
    );
    await task;
    return await ref.getDownloadURL();
  }
}

