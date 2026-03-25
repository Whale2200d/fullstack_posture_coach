/// 코치 대시보드·세션 리뷰에서 공통으로 쓰는 세션 식별 정보.
class CoachSessionItem {
  const CoachSessionItem({
    required this.sessionId,
    required this.userEmail,
    required this.exerciseName,
    this.videoDownloadUrl,
  });

  final String sessionId;
  final String userEmail;
  final String exerciseName;
  final String? videoDownloadUrl;

  /// Firestore `sessions` 문서 → UI 아이템 (Commit 40 저장 스키마와 동일)
  factory CoachSessionItem.fromFirestoreData(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final rawExercise = data['exerciseName'] as String? ?? '';
    final video = data['video'];
    String? downloadUrl;
    if (video is Map<String, dynamic>) {
      downloadUrl = video['downloadUrl'] as String?;
    } else if (video is Map) {
      final raw = video['downloadUrl'];
      if (raw is String) downloadUrl = raw;
    }
    return CoachSessionItem(
      sessionId: documentId,
      userEmail: data['userEmail'] as String? ?? '',
      exerciseName: _exerciseDisplayName(rawExercise),
      videoDownloadUrl:
          (downloadUrl != null && downloadUrl.isNotEmpty) ? downloadUrl : null,
    );
  }
}

String _exerciseDisplayName(String key) {
  switch (key) {
    case 'squat':
      return '스쿼트';
    case 'deadlift':
      return '데드리프트';
    default:
      return key.isEmpty ? '미지정' : key;
  }
}
