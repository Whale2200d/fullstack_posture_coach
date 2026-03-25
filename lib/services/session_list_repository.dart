import '../models/coach_session_item.dart';

/// 코치 대시보드용 세션 목록 (Firestore 등)
abstract class ISessionListRepository {
  Stream<List<CoachSessionItem>> watchRecentSessions({int limit = 50});
}
