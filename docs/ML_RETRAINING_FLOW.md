## Posture Coach – ML 재학습 플로우 (Commit 8)

MVP 이후, 코치 피드백을 활용해 **자세 교정 모델을 주기적으로 재학습**하는 전체 흐름을 정리합니다.

---

## 1. 전체 흐름 다이어그램 (텍스트)

```text
[1] 사용자 촬영/분석
    │
    ▼
 (앱, MediaPipe)
  - 카메라 영상 촬영
  - MediaPipe Pose로 랜드마크/각도 계산
  - 규칙 기반으로 1차 피드백 생성
  - 세션/분석 요약을 Firestore + Storage에 저장

[2] 코치 피드백 입력
    │
    ▼
 (웹 대시보드)
  - 코치가 세션 영상/분석 결과를 확인
  - 좋아요/싫어요 + 1~5점 + 코멘트 입력
  - feedback / ml_labels 컬렉션에 라벨 데이터 누적

[3] 재학습 트리거 (배치/주기)
    │
    ▼
 (Cloud Functions / Scheduler)
  - 일정 주기(예: 매일 새벽) 또는 라벨 개수 기준으로 재학습 작업 시작

[4] 데이터 수집/전처리
    │
    ▼
 (Cloud Functions or 별도 학습 서버)
  - Firestore의 ml_labels, sessions, exercise_types를 조회
  - 랜드마크/각도/템포 등 feature를 묶어 학습용 데이터셋 생성
  - 훈련/검증 세트로 분리

[5] 모델 재학습
    │
    ▼
 (TensorFlow / PyTorch 등)
  - 기존 모델(MediaPipe 기반 규칙/보정 또는 별도 TFLite 모델)을 로드
  - 코치 라벨(좋아요/싫어요, 점수)을 타깃으로 supervised learning 진행
  - 운동 타입·신체 정보별로 보정 파라미터를 학습할 수도 있음

[6] 성능 평가
    │
    ▼
  - 검증 세트에서 정확도, F1, MAE(각도 오차) 등 평가
  - 기준(예: 정확도 ≥ 85%) 충족 여부 판단

[7] 모델 배포
    │
    ▼
 (Cloud Storage / Remote Config)
  - 통과 시, 새 모델(TFLite 파일 또는 보정 파라미터)을 Storage에 업로드
  - 현재 활성화된 모델 버전/파라미터를 별도 컬렉션 또는 Remote Config에 기록

[8] 앱에서 새 모델 사용
    │
    ▼
 (앱 시작 시 또는 백그라운드 동기화)
  - 앱이 시작될 때 현재 모델 버전 확인
  - 필요하면 새 모델 파일/파라미터를 다운로드
  - 온디바이스 추론에 새 모델 적용
```

---

## 2. Firestore / Storage 연동 포인트

- `sessions`  
  - 각 세션의 분석 요약 및 feature 추출의 기본 소스.
- `feedback`  
  - 코치가 입력한 원시 피드백(좋아요/싫어요, 점수, 코멘트).
- `ml_labels`  
  - 재학습 시 실제로 사용할 **(features, target)** 쌍을 저장하는 컬렉션.
- `exercise_types`  
  - 운동별 구성(타겟 관절, 기본 각도 범위)을 정의해, 운동 타입별 모델/보정 파라미터를 다르게 운용하는 데 사용.
- `models` (추가 제안 컬렉션)

```json
// models/{modelId}
{
  "id": "pose_correction_v1",
  "type": "pose_correction",
  "version": 1,
  "exerciseTypeId": "squat",
  "storagePath": "models/pose_correction/squat/v1.tflite",
  "createdAt": "<Timestamp>",
  "metrics": {
    "accuracy": 0.87,
    "maeAngle": 5.3
  },
  "isActive": true
}
```

앱은 `models` 컬렉션에서 `isActive = true` 인 최신 버전만 읽어와 사용합니다.

---

## 3. Cloud Functions / 배치 작업 설계 메모

- **트리거 방식**
  - Cloud Scheduler → HTTP Cloud Function 호출 (주기적 배치)
  - 또는 Firestore `ml_labels` 문서 수 / 최근 추가 시간 기준 트리거.
- **실행 환경**
  - 간단한 보정/통계 기반 모델이면 Cloud Functions 내부에서 바로 학습·업데이트 가능.
  - 복잡한 딥러닝 모델이면, Cloud Functions는 **데이터 준비 + 학습 잡 제출**만 하고,
    실제 학습은 Cloud Run / Vertex AI / 외부 서버에서 수행.
- **로깅/모니터링**
  - 각 재학습 작업의 상태(시작/종료/성공/실패)와 메트릭을 Firestore `training_jobs` 컬렉션에 저장.

---

## 4. 앱 관점에서의 동작

1. 앱은 **기본 규칙 기반 + MediaPipe Pose** 로 항상 동작 가능해야 한다.  
   (ML 모델이 아직 없거나 로드 실패해도 최소한의 피드백을 줄 수 있어야 함.)
2. 재학습된 모델이 있을 경우:
   - 앱 시작 시 현재 모델 버전/파라미터를 확인.
   - 네트워크가 가능하면 백그라운드에서 새 모델 파일을 받는다.
   - 추론 시, 규칙 기반 피드백 + 학습된 모델의 출력을 함께 고려해 더 정교한 교정을 제공한다.
3. 사용자는 **업데이트를 인지하지 않아도 자연스럽게** 더 나은 피드백을 받게 된다.

---

## 5. 단계별 Commit 계획과 연결

- **Commit 7**: Firestore 스키마 정의 (`sessions`, `feedback`, `ml_labels` 등).
- **Commit 8 (본 문서)**: 재학습 플로우 설계, 어떤 컬렉션을 어떻게 사용할지 큰 그림 정의.
- 이후 개발 단계:
  - 코치 피드백 입력 UI/저장을 구현하면서 `feedback` / `ml_labels` 컬렉션에 실제 데이터 누적.
  - 별도 브랜치에서 Cloud Functions + 학습 파이프라인을 구현하고,
    `models`/`training_jobs` 컬렉션과 Storage를 사용해 재학습/배포를 자동화.

