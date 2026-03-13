# Commit 31: YOLOv8-Pose 실험 – 좌표 변환 유틸
#
# 이 모듈은 YOLOv8-Pose keypoints 출력(픽셀 좌표)을
# Flutter/MediaPipe 쪽에서 사용하는 것과 비슷한
# "정규화 랜드마크" 포맷으로 변환하는 도우미를 제공한다.
#
# 실제 YOLO 모델 실행은 별도 스크립트/노트북에서 처리하고,
# 여기서는 keypoints 배열만 전달받는다고 가정한다.

from typing import Dict, List


def yolo_keypoints_to_landmarks(
    keypoints: List[float],
    *,
    image_width: int,
    image_height: int,
) -> List[Dict]:
  """YOLOv8-Pose keypoints → 정규화 랜드마크 리스트로 변환.

  Args:
      keypoints: [x, y, confidence] * N 형식의 flat 리스트.
      image_width: 원본 이미지 가로 픽셀 수.
      image_height: 원본 이미지 세로 픽셀 수.

  Returns:
      [{"x": float, "y": float, "visibility": float}, ...]
      형태의 dict 리스트. 좌표는 0~1로 정규화된다.
  """
  if len(keypoints) % 3 != 0:
    raise ValueError("keypoints length must be multiple of 3 (x,y,conf per point).")

  landmarks: List[Dict] = []
  for i in range(0, len(keypoints), 3):
    x_px = keypoints[i]
    y_px = keypoints[i + 1]
    conf = keypoints[i + 2]

    landmarks.append(
      {
        "x": float(x_px) / float(image_width),
        "y": float(y_px) / float(image_height),
        "visibility": float(conf),
      }
    )

  return landmarks

