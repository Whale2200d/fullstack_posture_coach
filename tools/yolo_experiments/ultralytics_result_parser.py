from typing import List


def extract_keypoints_from_result(result) -> List[List[float]]:
  """Ultralytics YOLOv8 Pose result 객체에서 keypoints 배열만 추출한다.

  Args:
      result: Ultralytics YOLOv8 Pose 단일 이미지에 대한 결과 객체.
              최소한 .keypoints 속성이 있다고 가정한다.

  Returns:
      각 사람에 대한 keypoints 리스트.
      예: [[[x,y,conf], ...], ...] 중 한 사람의 [[x,y,conf], ...] 형태.
  """
  kpts = getattr(result, "keypoints", None)
  if kpts is None:
    return []

  data = getattr(kpts, "data", None)
  if data is None:
    return []

  # data: tensor[num_person, num_kpts, 3]
  persons = []
  for i in range(data.shape[0]):
    persons.append(data[i].tolist())  # [[x,y,conf], ...]

  return persons

