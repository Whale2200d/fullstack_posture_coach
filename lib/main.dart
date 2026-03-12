// Posture Coach - Entry point
// Commit 11: 앱 구조 정리 – 진입점만 유지

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/auth/auth_gate.dart';
import 'screens/coach/coach_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 현재는 iOS/Android에서만 Firebase 설정을 넣어두었으므로,
  // 그 플랫폼에서만 초기화를 시도한다.
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android)) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }

  runApp(const PostureCoachApp());
}

class PostureCoachApp extends StatelessWidget {
  const PostureCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CrossFit Posture Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routes: {
        '/coach': (_) => const CoachDashboardScreen(),
      },
      home: AuthGate(),
    );
  }
}
