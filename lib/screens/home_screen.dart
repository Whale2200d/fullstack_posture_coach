// Posture Coach - 홈 화면
// Commit 13: 홈 UI 업데이트 (운동 선택 + 촬영 버튼)

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.authService});

  final AuthService? authService;

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
          ],
        ),
      ),
    );
  }
}
