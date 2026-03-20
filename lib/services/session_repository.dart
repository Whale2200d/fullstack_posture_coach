// Commit 40: 세션(영상 업로드) 메타데이터 저장 인터페이스

class SessionRecord {
  const SessionRecord({
    required this.userEmail,
    required this.exerciseName,
    required this.storagePath,
    required this.downloadUrl,
    this.userId,
  });

  final String userEmail;
  final String exerciseName;
  final String storagePath;
  final String downloadUrl;
  final String? userId;

  /// Firestore `sessions` 문서 본문(타임스탬프 제외).
  Map<String, dynamic> toFirestoreMap() {
    return {
      'userEmail': userEmail,
      'exerciseName': exerciseName,
      if (userId != null && userId!.isNotEmpty) 'userId': userId,
      'video': {
        'storagePath': storagePath,
        'downloadUrl': downloadUrl,
      },
    };
  }
}

abstract class ISessionRepository {
  Future<void> save(SessionRecord record);
}

/// 테스트·로컬 개발용 인메모리 구현.
class InMemorySessionRepository implements ISessionRepository {
  final List<SessionRecord> saved = [];

  @override
  Future<void> save(SessionRecord record) async {
    saved.add(record);
  }
}
