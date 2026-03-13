# Commit 31 – YOLOv8-Pose 실험용 유틸

이 디렉터리는 MediaPipe와의 비교를 위해 YOLOv8-Pose를 실험할 때
공유해서 사용할 수 있는 **좌표 변환 유틸리티와 테스트**를 담고 있습니다.

## 구성

- `yolo_pose_utils.py`
  - YOLOv8-Pose keypoints 출력(픽셀 좌표, `[x, y, conf] * N`)을
    정규화 랜드마크 포맷으로 변환하는 함수 제공.
- `test_yolo_pose_utils.py`
  - 위 함수가 올바르게 정규화/매핑되는지 검증하는 Python `unittest`.

## 로컬에서 테스트 실행

```bash
cd tools/yolo_experiments

python3 -m unittest test_yolo_pose_utils.py
```

> 실제 YOLOv8-Pose 모델 실행(`ultralytics` 설치 등)은
> 별도 스크립트/노트북에서 처리하며,
> 이 디렉터리에서는 **모델 출력 후처리 부분만** 다룹니다.

## MediaPipe와의 연계

향후 YOLOv8-Pose 프로토타입(Commit 32~35)을 진행할 때:

1. Python에서 YOLOv8-Pose로 keypoints를 얻고,
2. `yolo_keypoints_to_landmarks(...)` 로 정규화한 뒤,
3. MediaPipe Pose에서 얻은 랜드마크와 동일한 스케일(0~1 좌표, visibility)로 비교할 수 있습니다.

이렇게 하면 두 모델의 출력 포맷 차이를 흡수한 뒤,
각도 계산/피드백 로직을 공통 코드로 재사용할 수 있습니다.

