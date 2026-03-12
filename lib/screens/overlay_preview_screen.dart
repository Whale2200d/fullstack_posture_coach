// Commit 18: 오버레이 시각적 확인용 화면
//
// 더미 랜드마크로 스켈레톤(빨간 선) 오버레이를 미리보기합니다.

import 'package:flutter/material.dart';

import '../services/pose_detection_service.dart';
import '../widgets/pose_skeleton_overlay.dart';

/// MediaPipe 33개 인덱스에 맞춘 더미 랜드마크 (서 있는 자세 형태)
List<LandmarkPoint> get _dummyLandmarks {
  return [
    const LandmarkPoint(x: 0.5, y: 0.12, visibility: 0.9),   // 0 nose
    const LandmarkPoint(x: 0.45, y: 0.10, visibility: 0.9),   // 1
    const LandmarkPoint(x: 0.44, y: 0.10, visibility: 0.9),   // 2 leftEye
    const LandmarkPoint(x: 0.43, y: 0.10, visibility: 0.9),   // 3
    const LandmarkPoint(x: 0.56, y: 0.10, visibility: 0.9),   // 4
    const LandmarkPoint(x: 0.56, y: 0.10, visibility: 0.9),   // 5 rightEye
    const LandmarkPoint(x: 0.57, y: 0.10, visibility: 0.9),   // 6
    const LandmarkPoint(x: 0.42, y: 0.11, visibility: 0.9),   // 7 leftEar
    const LandmarkPoint(x: 0.58, y: 0.11, visibility: 0.9),   // 8 rightEar
    const LandmarkPoint(x: 0.48, y: 0.14, visibility: 0.9),   // 9
    const LandmarkPoint(x: 0.52, y: 0.14, visibility: 0.9),   // 10
    const LandmarkPoint(x: 0.38, y: 0.22, visibility: 0.9),   // 11 leftShoulder
    const LandmarkPoint(x: 0.62, y: 0.22, visibility: 0.9),   // 12 rightShoulder
    const LandmarkPoint(x: 0.28, y: 0.35, visibility: 0.9),   // 13 leftElbow
    const LandmarkPoint(x: 0.72, y: 0.35, visibility: 0.9),   // 14 rightElbow
    const LandmarkPoint(x: 0.20, y: 0.48, visibility: 0.9),   // 15 leftWrist
    const LandmarkPoint(x: 0.80, y: 0.48, visibility: 0.9),   // 16 rightWrist
    const LandmarkPoint(x: 0.18, y: 0.50, visibility: 0.8),   // 17-22
    const LandmarkPoint(x: 0.82, y: 0.50, visibility: 0.8),
    const LandmarkPoint(x: 0.17, y: 0.52, visibility: 0.8),
    const LandmarkPoint(x: 0.83, y: 0.52, visibility: 0.8),
    const LandmarkPoint(x: 0.19, y: 0.48, visibility: 0.8),
    const LandmarkPoint(x: 0.81, y: 0.48, visibility: 0.8),
    const LandmarkPoint(x: 0.42, y: 0.45, visibility: 0.9),   // 23 leftHip
    const LandmarkPoint(x: 0.58, y: 0.45, visibility: 0.9),   // 24 rightHip
    const LandmarkPoint(x: 0.40, y: 0.62, visibility: 0.9),   // 25 leftKnee
    const LandmarkPoint(x: 0.60, y: 0.62, visibility: 0.9),   // 26 rightKnee
    const LandmarkPoint(x: 0.38, y: 0.80, visibility: 0.9),   // 27 leftAnkle
    const LandmarkPoint(x: 0.62, y: 0.80, visibility: 0.9),   // 28 rightAnkle
    const LandmarkPoint(x: 0.37, y: 0.84, visibility: 0.8),   // 29 leftHeel
    const LandmarkPoint(x: 0.63, y: 0.84, visibility: 0.8),   // 30 rightHeel
    const LandmarkPoint(x: 0.36, y: 0.88, visibility: 0.8),   // 31
    const LandmarkPoint(x: 0.64, y: 0.88, visibility: 0.8),   // 32
  ];
}

class OverlayPreviewScreen extends StatelessWidget {
  const OverlayPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자세 오버레이 미리보기'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PoseSkeletonOverlay(
                  landmarks: _dummyLandmarks,
                  lineColor: Colors.red,
                  child: Container(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
