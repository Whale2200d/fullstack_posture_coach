from typing import List


def extract_keypoints_from_result(result) -> List[List[float]]:
  """Ultralytics YOLOv8 Pose result 객체에서 keypoints 배열만 추출한다.

  Args:
      result: Ultralytics YOLOv8 Pose 단일 이미지에 대한 결과 객체.
              최소한 .keypoints 속성이 있다고 가정한다.

  Returns:
      각 사람에 대한 keypoints flat 리스트의 리스트.
      예: [[x1,y1,conf1, x2,y2,conf2,...], [...], ...]
  """
  keypoints = getattr(result, "keypoints", None)
  if keypoints is None:
    return []
  return [list(kp) for kp in keypoints]

