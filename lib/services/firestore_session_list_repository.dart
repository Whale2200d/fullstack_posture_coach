import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/coach_session_item.dart';
import 'session_list_repository.dart';

class FirestoreSessionListRepository implements ISessionListRepository {
  FirestoreSessionListRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<CoachSessionItem>> watchRecentSessions({int limit = 50}) {
    return _firestore
        .collection('sessions')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => CoachSessionItem.fromFirestoreData(
                  d.id,
                  d.data(),
                ),
              )
              .toList(),
        );
  }
}
