// Posture Coach - 홈 화면
// Commit 13: 홈 UI 업데이트 (운동 선택 + 촬영 버튼)
// Commit 16: 자세 감지 준비 버튼 (MediaPipe 샘플 로그)
// Commit 17: detect() 호출 후 랜드마크 콘솔 출력

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/pose_detection_mediapipe_adapter.dart';
import '../services/pose_detection_service.dart';
import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.authService});

  final AuthService? authService;

  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  Future<void> _onPoseDetectionReady(BuildContext context) async {
    if (!_isMobile) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('자세 감지는 iOS/Android에서만 사용 가능합니다.'),
        ),
      );
      return;
    }
    try {
      final service = PoseDetectionService(
        adapter: MediaPipePoseDetectorAdapter(),
      );
      await service.initialize();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('자세 감지 준비됨 (MediaPipe)')),
      );
      debugPrint('PoseDetectionService initialized (MediaPipe)');

      // Commit 17: 샘플 입력으로 detect() 호출 후 랜드마크 콘솔 출력
      final sampleBytes = Uint8List(256);
      final result = await service.detect(sampleBytes);
      debugPrint('PoseDetectionResult: $result');
      for (var i = 0; i < result.landmarks.length && i < 5; i++) {
        debugPrint('  landmark[$i]: ${result.landmarks[i]}');
      }
    } catch (e, st) {
      debugPrint('Pose detection init failed: $e');
      debugPrint(st.toString());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('자세 감지 준비 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CrossFit Posture Coach'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (authService != null)
            TextButton(
              onPressed: () async {
                await authService!.signOut();
              },
              child: const Text('로그아웃'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '자세 교정 앱',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '환경 세팅 완료 후 촬영·분석 기능이 추가됩니다.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '오늘의 운동',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: const [
                Chip(
                  label: Text('스쿼트'),
                  avatar: Icon(Icons.directions_run, size: 16),
                ),
                Chip(
                  label: Text('데드리프트'),
                  avatar: Icon(Icons.fitness_center, size: 16),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.videocam),
                label: const Text('촬영 시작'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CameraScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.psychology),
                label: const Text('자세 감지 준비'),
                onPressed: () => _onPoseDetectionReady(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
