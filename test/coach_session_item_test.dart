// Commit 41: Firestore 문서 → CoachSessionItem 매핑 TDD

import 'package:flutter_test/flutter_test.dart';
import 'package:posture_coach/models/coach_session_item.dart';

void main() {
  test('fromFirestoreData가 Commit 40 sessions 스키마를 매핑한다', () {
    final item = CoachSessionItem.fromFirestoreData('docAbc', {
      'userEmail': 'u@example.com',
      'exerciseName': 'squat',
      'video': {
        'storagePath': 'videos/x.mp4',
        'downloadUrl': 'https://example.com/x',
      },
    });

    expect(item.sessionId, 'docAbc');
    expect(item.userEmail, 'u@example.com');
    expect(item.exerciseName, '스쿼트');
    expect(item.videoDownloadUrl, 'https://example.com/x');
  });

  test('deadlift는 데드리프트로 표시된다', () {
    final item = CoachSessionItem.fromFirestoreData('id', {
      'userEmail': '',
      'exerciseName': 'deadlift',
    });
    expect(item.exerciseName, '데드리프트');
  });
}
