// Commit 40: Firestore `sessions` 컬렉션에 세션 메타데이터 저장

import 'package:cloud_firestore/cloud_firestore.dart';

import 'session_repository.dart';

class FirestoreSessionRepository implements ISessionRepository {
  FirestoreSessionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> save(SessionRecord record) async {
    await _firestore.collection('sessions').add({
      ...record.toFirestoreMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
