## Posture Coach – 자세 추정 모델 비교 (Commit 6)

이 문서는 **자세 추정(포즈 에스티메이션)** 용으로 사용할 후보 모델들을 비교하고,  
MVP 단계에서 **MediaPipe Pose** 를 기본 선택으로 하는 이유를 기록합니다.

---

## 1. 후보 모델 개요

| 항목 | MediaPipe Pose | YOLOv8-Pose |
|------|----------------|-------------|
| 개발사/프로젝트 | Google MediaPipe | Ultralytics YOLOv8 |
| 아키텍처 | BlazePose 기반 경량 포즈 모델 | YOLOv8 기반 multi-head (object + keypoints) |
| 출력 | 33개(또는 25개) 전신 랜드마크 | 사람 박스 + 관절 키포인트(개수 설정 가능) |
| 배포 형태 | Android/iOS/웹용 SDK, TFLite | PyTorch, ONNX, TFLite 등 |
| 포커스 | 온디바이스, 실시간, 경량 | 고성능, 복잡/혼잡 장면 처리 |

---

## 2. 성능/정확도 관점 비교

### 2.1 실시간 성능 (FPS, 지연시간)

- **MediaPipe Pose (특히 Lite 구성)**  
  - 모바일 기기에서 **높은 FPS와 낮은 지연시간**을 제공하도록 설계됨.  
  - 연구 비교 결과에서도, 리소스가 제한된 환경에서 **실시간 성능이 우수**한 것으로 보고됨.
- **YOLOv8-Pose**  
  - nano/small 등 경량 모델도 존재하지만, 기본적으로 **연산량(GFLOPs)와 파라미터 수가 더 크다**.  
  - 복잡한 장면(사람이 많거나 가려지는 경우)을 잘 처리하는 대신, **모바일 디바이스에서는 프레임 레이트 희생 가능성**이 큼.

### 2.2 정확도 및 복잡 장면 처리

- MediaPipe:
  - 단일 인체, 비교적 깔끔한 환경에서 **높은 관절 정확도**를 달성하는 사례가 보고됨.
  - 특정 임상/재활 환경 비교 실험에서, 주요 관절 정확도가 90% 이상 수준으로 보고된 연구도 있음.
- YOLOv8-Pose:
  - 다중 인물, 가려짐(occlusion)이 있는 **복잡/혼잡 장면**에서 강점을 보임.
  - 크고 깊은 모델(large, xlarge)은 정확도가 높지만, 모바일 온디바이스에는 부담스러운 크기와 연산량을 가짐.

이 앱의 1차 목표는 **단일 사용자(한 명의 운동자)** 의 자세를 실시간으로 코칭하는 것이므로,  
복잡 장면(군중, 다중 인물)에 대한 이점보다 **지연시간/경량성**이 더 중요합니다.

---

## 3. 개발/통합 관점 비교

| 관점 | MediaPipe Pose | YOLOv8-Pose |
|------|----------------|-------------|
| Flutter 통합 | 커뮤니티 패키지(`mediapipe_flutter` 등)를 통해 바로 사용 가능, 샘플 코드 다수 | 보통 PyTorch/ONNX → TFLite 변환 후, 별도 플러그인(예: `tflite_flutter`)으로 직접 추론 파이프라인 구성 필요 |
| 모바일 SDK | Android/iOS용 공식/준공식 가이드 풍부 | 주로 Python/서버/데스크톱 예제가 중심, 모바일은 추가 작업 필요 |
| 설정 복잡도 | 비교적 단순: 입력 영상 → 모델 호출 → 랜드마크 후처리 | 객체 검출 + 키포인트 후처리를 함께 구현해야 함 |
| 초기 학습 곡선 | 상대적으로 완만 | 모델/배포 파이프라인에 대한 이해가 더 많이 필요 |

---

## 4. Posture Coach 관점의 요구사항과 매핑

요구사항(`docs/REQUIREMENTS.md`) 기준으로 모델 선택에 영향을 주는 요소를 정리하면:

1. **실시간 피드백 (24~30fps 목표)** – 모바일 디바이스에서 지연 없이 자세 교정 오버레이를 보여줘야 함.
2. **단일 사용자 중심** – 한 화면에 한 명의 운동자만 분석하는 시나리오가 기본.
3. **온디바이스 처리 우선** – 개인정보 보호, 네트워크 지연 최소화를 위해 가능하면 디바이스 내에서 추론.
4. **Flutter와의 통합 용이성** – 카메라 프리뷰 → 포즈 추론 → CustomPaint 오버레이까지 빠르게 프로토타입을 만들 수 있어야 함.
5. **향후 확장성** – 나중에 YOLOv8-Pose 기반의 동적/복잡 장면 분석으로 확장 가능해야 함.

이 기준에서:

- MediaPipe Pose는 **1~4번 요구사항을 바로 만족**시키기에 적합.
- YOLOv8-Pose는 **5번(확장성)** 의 좋은 후보지만, 초기 MVP에서 바로 채택하기엔 구현/성능 부담이 크다.

---

## 5. 결론 – MVP 단계 모델 선택 전략

1. **MVP (현재 단계)**
   - **기본 모델**: MediaPipe Pose (Lite/Full 구성 중 디바이스 성능에 맞게 선택)
   - 이유:
     - 모바일 온디바이스에서 실시간 프레임 속도 확보가 쉽다.
     - Flutter와의 통합 예제가 많고, 빠르게 카메라 + 오버레이 프로토타입을 만들 수 있다.
     - 단일 사용자 자세 교정 시나리오에는 충분한 관절 정확도를 제공한다.

2. **Phase 2 이후 (확장/연구)**
   - 별도 브랜치에서 **YOLOv8-Pose** 를 통합/벤치마크:
     - 속도: MediaPipe 대비 FPS/지연시간 측정 (Android/iOS 실제 기기 기준).
     - 정확도: 각 운동별(스쿼트/데드리프트/요가 등) 랜드마크/각도 정확도 비교.
     - 복잡 장면: 두 명 이상이 화면에 있을 때, 혹은 가려짐이 있을 때의 성능 평가.
   - 특정 시나리오(예: 단체 수업, 군중 속 자세 인식)가 필요해질 경우 YOLOv8-Pose 기반 파이프라인을 선택적으로 도입.

3. **구현 전략 요약**
   - 코드 구조를 **“포즈 추정 인터페이스” + “MediaPipe 구현체”** 로 구성해,  
     나중에 YOLOv8-Pose 구현체를 추가하는 방식으로 확장 가능하게 설계한다.
   - ML/감지 로직은 `lib/ml/pose/` 같은 별도 모듈로 분리해, 프론트엔드 UI와 의존성을 느슨하게 유지한다.

---

## 6. 간단 실험 결과 요약 (Commit 31~34)

> 아래 결과는 로컬 Mac 환경에서 **예시 이미지 1장** 기준으로 측정한,  
> 초기 프로토타입 수준의 관찰값입니다. 최종 벤치마크가 아니라 방향성 참고용입니다.

- **테스트 환경**
  - 기기: Apple Silicon Mac (로컬 Python)
  - 모델: `yolov8n-pose.pt`
  - 이미지: `crossfit_squat_side_view.jpg` (단일 인물, 스쿼트 옆모습)

- **YOLOv8-Pose**
  - 추론 속도: 약 **45~55ms / 이미지 1장** (로그 기준: `41.5ms`, `49.6ms` 등)
  - 출력: `keypoints.shape = torch.Size([1, 17, 3])` (1명, 17개 관절, (x,y,conf))
  - `tools/yolo_experiments/yolo_pose_utils.py` 로 정규화한 결과:
    - `x, y` 는 0~1 범위, `visibility` 에 confidence(0~1) 매핑
    - 무릎/엉덩이/어깨 등 주요 관절 위치가 시각적으로 자연스러움

- **MediaPipe Pose (예상/기존 문헌 + 모바일 기준)**
  - 모바일 디바이스에서 Lite 구성 기준 **~30fps(≒ 33ms/frame) 이상** 보고 사례 다수
  - 33개 랜드마크 제공, 상·하체/발끝까지 보다 세밀한 포인트를 제공
  - Flutter 연동이 이미 구현되어 있고(on-device), 실시간 미리보기와 잘 결합됨

- **1장 이미지 기준 결론**
  - YOLOv8-Pose(nano)는 속도가 나쁘지 않지만,  
    - Mac 데스크톱에서 ~50ms 수준 → 모바일 온디바이스로 옮기면 더 느려질 가능성이 큼.
  - MediaPipe Pose는 이미 **모바일 실시간용으로 최적화된 구조 + 풍부한 Flutter 통합 예제**를 갖고 있어,  
    초기 MVP에서는 여전히 MediaPipe를 메인으로 사용하는 것이 합리적이다.

---

## 7. Commit/히스토리에서의 역할

- **Commit 6** 에서는 실제 코드 변경 대신,  
  - MediaPipe Pose vs YOLOv8-Pose 의 **비교 문서**를 추가하고,
  - 왜 현재는 MediaPipe를 선택하는지, 언제 YOLOv8-Pose를 재검토할지 기준을 명시했다.
- 추후 YOLOv8-Pose 프로토타입을 구현할 때, 이 문서를 참고해:
  - 어떤 지표(FPS, 정확도, 리소스 사용량)를 비교해야 하는지
  - 어떤 시나리오(단일/다중 인물)를 테스트해야 하는지  
  를 빠르게 파악할 수 있다.

---

## 8. 정식 채택 – 앱 내 공식 모델 경로 (Commit 36)

YOLO 실험(Commit 31~35) 결과를 바탕으로, **앱에서 사용하는 포즈 추정 파이프라인은 MediaPipe 기반으로 정식 채택**합니다.

- **채택 모델**: MediaPipe Pose (Flutter: `flutter_pose_detection` 패키지, `NpuPoseDetector` 사용)
- **실험 코드 위치**: YOLOv8-Pose 관련 코드는 `tools/yolo_experiments/` 에만 두며, 앱(`lib/`)에서는 사용하지 않음. 추후 Phase 2 등에서 재검토 시 참고용으로 활용.

### 8.1 앱 내 공식 파이프라인 구성

| 역할 | 파일 | 설명 |
|------|------|------|
| 포즈 추정 인터페이스/결과 | `lib/services/pose_detection_service.dart` | `IPoseDetector`, `PoseDetectionResult`, `LandmarkPoint`, `PoseDetectionService` |
| MediaPipe 구현체 | `lib/services/pose_detection_mediapipe_adapter.dart` | `MediaPipePoseDetectorAdapter` – `flutter_pose_detection`의 `NpuPoseDetector` 래핑 |
| 각도 계산 | `lib/services/pose_angle_math.dart` | 세 점 기준 각도(도 단위) 계산 |
| 자세 분석 | `lib/services/posture_analyzer.dart` | `PostureAnalyzer` – 랜드마크 → 각도/이슈 도출, `PostureAnalysisResult` |
| 스켈레톤 오버레이 | `lib/widgets/pose_skeleton_overlay.dart` | `PoseSkeletonOverlay`, `PoseSkeletonPainter` – 랜드마크를 선으로 그리기 |

실시간 플로우: **카메라 프레임 → PoseDetectionService.detect() → LandmarkPoint 목록 → PostureAnalyzer.analyze() → 코칭 서비스/오버레이**.  
새 포즈 모델을 붙일 경우 `IPoseDetector` 구현체만 추가/교체하면 되도록 설계되어 있습니다.

