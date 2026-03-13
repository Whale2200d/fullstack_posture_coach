# Commit 31: YOLOv8-Pose 실험 – 좌표 변환 유틸
#
# 이 모듈은 YOLOv8-Pose keypoints 출력(픽셀 좌표)을
# Flutter/MediaPipe 쪽에서 사용하는 것과 비슷한
# "정규화 랜드마크" 포맷으로 변환하는 도우미를 제공한다.
#
# 실제 YOLO 모델 실행은 별도 스크립트/노트북에서 처리하고,
# 여기서는 keypoints 배열만 전달받는다고 가정한다.

from typing import Dict, List, Sequence, Union


def yolo_keypoints_to_landmarks(
    keypoints: Union[List[float], Sequence[Sequence[float]]],
    *,
    image_width: int,
    image_height: int,
) -> List[Dict]:
  """YOLOv8-Pose keypoints → 정규화 랜드마크 리스트로 변환.

  Args:
      keypoints:
          - Ultralytics YOLOv8 Pose에서 흔히 쓰는 형태:
            [[x, y, confidence], ...] (torch.Size([num_kpts, 3])와 유사)
          - 또는 기존 테스트용 flat 포맷:
            [x1, y1, c1, x2, y2, c2, ...]
      image_width: 원본 이미지 가로 픽셀 수.
      image_height: 원본 이미지 세로 픽셀 수.

  Returns:
      [{"x": float, "y": float, "visibility": float}, ...]
      형태의 dict 리스트. 좌표는 0~1로 정규화된다.
  """
  # 빈 입력 처리
  if not keypoints:
    return []

  # YOLOv8 Pose의 실제 출력 형태(torch.Size([num_kpts, 3]))를 지원하기 위해
  # 먼저 [ [x,y,conf], ... ] 형식인지 검사하고, 맞다면 flat 리스트로 변환한다.
  first = keypoints[0]
  flat: List[float] = []
  if isinstance(first, (list, tuple)):
    for triplet in keypoints:  # type: ignore[arg-type]
      if len(triplet) < 2:
        continue
      x_px = triplet[0]
      y_px = triplet[1]
      conf = triplet[2] if len(triplet) > 2 else 1.0
      flat.extend([x_px, y_px, conf])
  else:
    flat = list(keypoints)  # type: ignore[list-item]

  if len(flat) % 3 != 0:
    raise ValueError("keypoints length must be multiple of 3 (x,y,conf per point).")

  landmarks: List[Dict] = []
  for i in range(0, len(flat), 3):
    x_px = flat[i]
    y_px = flat[i + 1]
    conf = flat[i + 2]

    landmarks.append(
      {
        "x": float(x_px) / float(image_width),
        "y": float(y_px) / float(image_height),
        "visibility": float(conf),
      }
    )

  return landmarks

