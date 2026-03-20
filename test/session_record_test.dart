// Commit 40: SessionRecord Firestore 맵 형태 TDD

import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/services/session_repository.dart';

void main() {
  group('SessionRecord.toFirestoreMap', () {
    test('userId가 있으면 맵에 포함된다', () {
      const record = SessionRecord(
        userEmail: 'u@example.com',
        exerciseName: 'squat',
        storagePath: 'videos/1.mp4',
        downloadUrl: 'https://example.com/v.mp4',
        userId: 'uid123',
      );
      expect(record.toFirestoreMap(), {
        'userEmail': 'u@example.com',
        'exerciseName': 'squat',
        'userId': 'uid123',
        'video': {
          'storagePath': 'videos/1.mp4',
          'downloadUrl': 'https://example.com/v.mp4',
        },
      });
    });

    test('userId가 null이면 맵에 userId 키가 없다', () {
      const record = SessionRecord(
        userEmail: '',
        exerciseName: 'deadlift',
        storagePath: 'videos/2.mp4',
        downloadUrl: 'https://x/y',
      );
      final m = record.toFirestoreMap();
      expect(m.containsKey('userId'), isFalse);
      expect(m['exerciseName'], 'deadlift');
    });
  });

  group('InMemorySessionRepository', () {
    test('save 후 목록에 쌓인다', () async {
      final repo = InMemorySessionRepository();
      const r = SessionRecord(
        userEmail: 'a@b.com',
        exerciseName: 'squat',
        storagePath: 'p',
        downloadUrl: 'u',
      );
      await repo.save(r);
      expect(repo.saved.length, 1);
      expect(repo.saved.first.userEmail, 'a@b.com');
    });
  });
}
