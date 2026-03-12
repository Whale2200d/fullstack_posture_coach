// Commit 29: 알림 서비스 인터페이스

abstract class INotificationService {
  Future<void> sendLocal(String title, String body);
}

