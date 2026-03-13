# Commit 31: YOLOv8-Pose 실험 – 좌표 변환 유틸 TDD
#
# 실제 YOLO 모델 실행은 별도 환경에서 하되,
# 이 테스트는 "YOLO 포맷의 keypoints → 내부 공통 포맷" 변환 로직만 검증한다.

import unittest

from yolo_pose_utils import yolo_keypoints_to_landmarks


class YoloPoseUtilsTest(unittest.TestCase):
  def test_convert_yolo_keypoints_to_landmarks(self):
    # YOLOv8-Pose keypoints 포맷 예시: [x, y, confidence] * N
    # 여기서는 임의의 두 랜드마크만 사용.
    keypoints = [
      100.0,
      200.0,
      0.9,  # nose
      150.0,
      250.0,
      0.8,  # left_eye
    ]
    image_w, image_h = 640, 480

    landmarks = yolo_keypoints_to_landmarks(
      keypoints, image_width=image_w, image_height=image_h
    )

    self.assertEqual(len(landmarks), 2)
    nose = landmarks[0]
    left_eye = landmarks[1]

    # 정규화 좌표 검증
    self.assertAlmostEqual(nose["x"], 100.0 / image_w)
    self.assertAlmostEqual(nose["y"], 200.0 / image_h)
    self.assertAlmostEqual(nose["visibility"], 0.9)

    self.assertAlmostEqual(left_eye["x"], 150.0 / image_w)
    self.assertAlmostEqual(left_eye["y"], 250.0 / image_h)
    self.assertAlmostEqual(left_eye["visibility"], 0.8)


if __name__ == "__main__":
  unittest.main()

