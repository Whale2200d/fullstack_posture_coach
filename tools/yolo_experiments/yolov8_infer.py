# Commit 32: YOLOv8-Pose 추론 데모 스크립트
"""
로컬 Python 환경에서 YOLOv8-Pose를 테스트하기 위한 예시 스크립트입니다.

필요 전제:
  pip install ultralytics

사용 예:
  cd tools/yolo_experiments
  python3 yolov8_infer.py --image path/to/image.jpg
"""

import argparse

from ultralytics import YOLO

from yolo_pose_utils import yolo_keypoints_to_landmarks
from ultralytics_result_parser import extract_keypoints_from_result


def main():
  parser = argparse.ArgumentParser()
  parser.add_argument("--image", required=True, help="Input image path")
  parser.add_argument(
    "--model", default="yolov8n-pose.pt", help="YOLOv8 pose model path"
  )
  args = parser.parse_args()

  model = YOLO(args.model)
  results = model(args.image)

  for i, res in enumerate(results):
    # 디버그: keypoints 구조 출력
    kpts = getattr(res, "keypoints", None)
    print(f"[Result {i}] keypoints type={type(kpts)}, shape={getattr(kpts, 'shape', None)}")

    keypoints_list = extract_keypoints_from_result(res)
    print(f"[Result {i}] found {len(keypoints_list)} persons")

    for person_idx, kps in enumerate(keypoints_list):
      print(f"  raw keypoints[{person_idx}]: {kps[:2]}")
      landmarks = yolo_keypoints_to_landmarks(
        kps,
        image_width=res.orig_shape[1],
        image_height=res.orig_shape[0],
      )
      print(f"  Person {person_idx}: first 2 landmarks = {landmarks[:2]}")


if __name__ == "__main__":
  main()

