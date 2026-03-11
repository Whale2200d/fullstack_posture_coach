// Posture Coach - 카메라 화면 (플레이스홀더)
// Commit 13: 촬영 진입 지점만 구성

import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('촬영 (카메라 준비 중)'),
      ),
      body: Center(
        child: Text(
          '여기에 카메라 프리뷰와 자세 분석 오버레이가 들어갈 예정입니다.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

