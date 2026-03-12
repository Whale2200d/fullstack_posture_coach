// Commit 26: 피드백 데이터 저장용 인터페이스/모델

class FeedbackData {
  FeedbackData({
    required this.sessionId,
    required this.userEmail,
    required this.exerciseName,
    required this.isPositive,
    required this.score,
  });

  final String sessionId;
  final String userEmail;
  final String exerciseName;
  final bool? isPositive; // null: 선택 안 함, true: 좋아요, false: 싫어요
  final int score; // 1~5
}

abstract class IFeedbackRepository {
  Future<void> saveFeedback(FeedbackData data);
}

