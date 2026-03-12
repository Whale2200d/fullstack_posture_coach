// Commit 29: Firebase Messaging 기반 알림 서비스 (앱 측 래퍼)

import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_service.dart';

class FirebaseNotificationService implements INotificationService {
  FirebaseNotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<void> init() async {
    await _messaging.requestPermission();
    await _messaging.getToken();
  }

  @override
  Future<void> sendLocal(String title, String body) async {
    // 실제 푸시는 서버에서 FCM API를 통해 전송해야 하므로,
    // 여기서는 추후 flutter_local_notifications 연동을 위해 비워둔다.
    // 현재 Commit 29에서는 테스트용 인터페이스 역할만 수행한다.
  }
}

