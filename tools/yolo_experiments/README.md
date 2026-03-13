# Commit 31 – YOLOv8-Pose 실험용 유틸

이 디렉터리는 MediaPipe와의 비교를 위해 YOLOv8-Pose를 실험할 때
공유해서 사용할 수 있는 **좌표 변환 유틸리티와 테스트**를 담고 있습니다.

## 구성

- `yolo_pose_utils.py`
  - YOLOv8-Pose keypoints 출력(픽셀 좌표, `[x, y, conf] * N`)을
    정규화 랜드마크 포맷으로 변환하는 함수 제공.
- `test_yolo_pose_utils.py`
  - 위 함수가 올바르게 정규화/매핑되는지 검증하는 Python `unittest`.
- `ultralytics_result_parser.py`
  - Ultralytics YOLOv8 Pose 결과 객체에서 `keypoints` 배열만 추출하는 헬퍼.
- `test_ultralytics_result_parser.py`
  - 가짜 결과 객체를 사용해 keypoints 추출 로직을 검증하는 테스트.
- `yolov8_infer.py`
  - 실제 YOLOv8-Pose 모델을 사용해 이미지 하나를 추론하고,
    keypoints → 정규화 랜드마크로 변환해 출력하는 데모 스크립트.

## 로컬에서 테스트 실행

```bash
cd tools/yolo_experiments

python3 -m unittest test_yolo_pose_utils.py
python3 -m unittest test_ultralytics_result_parser.py

# YOLOv8-Pose 데모 (로컬에서 ultralytics 설치 후)
python3 yolov8_infer.py --image path/to/image.jpg
```

> 실제 YOLOv8-Pose 모델 실행(`ultralytics` 설치 등)은
> `yolov8_infer.py` 와 별도 노트북에서 처리하며,
> 이 디렉터리에서는 **모델 출력 후처리 및 간단 데모**를 다룹니다.

## MediaPipe와의 연계

향후 YOLOv8-Pose 프로토타입(Commit 32~35)을 진행할 때:

1. Python에서 YOLOv8-Pose로 keypoints를 얻고,
2. `yolo_keypoints_to_landmarks(...)` 로 정규화한 뒤,
3. MediaPipe Pose에서 얻은 랜드마크와 동일한 스케일(0~1 좌표, visibility)로 비교할 수 있습니다.

이렇게 하면 두 모델의 출력 포맷 차이를 흡수한 뒤,
각도 계산/피드백 로직을 공통 코드로 재사용할 수 있습니다.
