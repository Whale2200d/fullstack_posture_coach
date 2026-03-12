// Commit 26: Firestore 기반 피드백 저장소 구현

import 'package:cloud_firestore/cloud_firestore.dart';

import 'feedback_repository.dart';

class FirestoreFeedbackRepository implements IFeedbackRepository {
  FirestoreFeedbackRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> saveFeedback(FeedbackData data) async {
    // 단순화: feedback 컬렉션에 한 문서로 저장
    await _firestore.collection('feedback').add({
      'sessionId': data.sessionId,
      'userEmail': data.userEmail,
      'exerciseName': data.exerciseName,
      'label': {
        'isPositive': data.isPositive,
        'score': data.score,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

