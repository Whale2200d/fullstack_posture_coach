## Posture Coach – 전체 기획 개요 (Commit 10)

이 문서는 현재까지 정리한 **모든 기획/설계 문서의 요약과 연결점**을 한눈에 볼 수 있게 정리한 개요입니다.

---

## 1. 비전 & MVP 범위

- **비전**
  - 카메라 기반 자세 분석으로 크로스 트레이닝, 요가, 웨이트 등 다양한 운동을 **실시간으로 교정**하는 개인 맞춤 코치 앱.
  - 코치 피드백을 활용한 **지속적인 ML 재학습**으로 시간이 지날수록 더 똑똑해지는 시스템.

- **MVP 범위 (Phase 1)**
  - 운동: 스쿼트, 데드리프트 중심.
  - 플랫폼: iOS/Android + macOS/Chrome.
  - **포즈 추정**: MediaPipe Pose를 **정식 채택** (Commit 36). YOLO 실험(31~35) 후 앱 내 공식 경로는 `PoseDetectionService` + `MediaPipePoseDetectorAdapter` + `PostureAnalyzer` 조합. 상세는 `docs/ML_MODEL_COMPARISON.md` §8 참고.
  - 핵심 플로우:
    1. 로그인 → 신체 정보 입력
    2. 카메라 촬영 → MediaPipe Pose로 랜드마크/각도 계산
    3. 규칙 기반 시각/텍스트 피드백 (오버레이/문구/음성)
    4. 세션 기록 저장 (Firestore + Storage)
    5. 코치가 웹 대시보드에서 영상 리뷰 + 라벨(좋아요/점수) 입력
  - ML: MediaPipe Pose + 규칙 기반 분석, 코치 피드백은 재학습용 라벨로만 사용 (파이프라인 정의 단계).

자세한 요구사항은 `docs/REQUIREMENTS.md` 를 참고합니다.

---

## 2. 문서 구조 한눈에 보기

- **환경/설치**
  - `docs/FLUTTER_SETUP.md` – Flutter 설치, 시뮬레이터/에뮬레이터 설정, iOS/Android/웹 실행 방법.
  - `docs/FIREBASE_SETUP.md` – Firebase 프로젝트 생성, iOS/Android 앱 등록, Flutter에서 `Firebase.initializeApp` 사용 방법.

- **기능/UX/확장**
  - `docs/REQUIREMENTS.md` – 사용자/코치/ML/시스템 기능 요구사항 + 비기능 요구사항.
  - `docs/UI_WIREFRAME.md` – 사용자 앱 & 코치 대시보드 화면 구조/플로우.
  - `docs/EXPANSION_PLAN.md` – 요가/웨이트/개인화/YOLOv8 확장을 위한 로드맵.

- **ML/데이터**
  - `docs/ML_MODEL_COMPARISON.md` – MediaPipe Pose vs YOLOv8-Pose 비교 및 MVP 모델 선택 이유.
  - `docs/DB_SCHEMA_FIRESTORE.md` – Firestore 컬렉션/문서 구조, ML 라벨 데이터 스키마.
  - `docs/ML_RETRAINING_FLOW.md` – 코치 피드백 기반 ML 재학습/배포 플로우 정의.

---

## 3. 엔드투엔드 흐름 요약

```text
[사용자 앱]
 1) 로그인/온보딩
 2) 신체 정보 입력 (users.profile)
 3) 운동 선택 → 카메라 촬영
 4) MediaPipe Pose로 자세 분석, 규칙 기반 피드백 표시
 5) 세션/분석 결과 Firestore(sessions) + Storage(영상) 저장

[코치 대시보드]
 6) 사용자/세션 목록 조회
 7) 영상/분석 결과 확인
 8) 좋아요/싫어요 + 1~5점 + 코멘트 입력 (feedback, ml_labels)

[ML 파이프라인]
 9) Cloud Functions/배치가 ml_labels 데이터를 모아 재학습 잡 실행
10) 모델 평가(정확도 ≥ 85% 등) 후, 새 모델/보정 파라미터를 Storage + Firestore(models)에 기록

[앱 업데이트]
11) 앱 시작 시 최신 모델/파라미터 확인
12) 새 모델이 있으면 백그라운드 다운로드 후, 규칙 기반 + 학습 모델을 조합해 더 정교한 피드백 제공
```

---

## 4. 개발 단계와 문서의 매핑 (Commit 1~10)

- **Commit 1~3** – 환경/플랫폼/기본 Firebase 연결
  - `.gitignore`, Flutter 프로젝트 구조, iOS/Android/웹 실행 방법 (`FLUTTER_SETUP`), Firebase 프로젝트/앱 연결 (`FIREBASE_SETUP`).

- **Commit 4~5** – 요구사항 & UI
  - 요구사항 정의서 (`REQUIREMENTS`), 사용자/코치 UI 와이어프레임 (`UI_WIREFRAME`).

- **Commit 6~8** – ML/데이터 설계
  - 모델 비교 (`ML_MODEL_COMPARISON`), Firestore 스키마 (`DB_SCHEMA_FIRESTORE`), 재학습 플로우 (`ML_RETRAINING_FLOW`).

- **Commit 9~10** – 확장/전체 기획 정리
  - 확장 계획 (`EXPANSION_PLAN`), 전체 개요 및 문서 구조 (`PROJECT_OVERVIEW` – 본 문서).

---

## 5. 이후 개발 단계에서의 활용

1. **기능 구현 시**
   - 요구사항/와이어프레임 문서를 보며 Flutter 화면/상태를 설계.
   - Firestore 스키마 문서를 보고 `collection/doc` 구조와 필드 이름을 맞춘다.

2. **ML/백엔드 작업 시**
   - 모델 비교/재학습 플로우 문서를 기준으로 실험/배치를 진행.
   - 필요 시 문서를 업데이트해 Commit 히스토리와 함께 설계 변경 사항을 남긴다.

3. **온보딩/협업 시**
   - 새 팀원에게 `README.md` → `PROJECT_OVERVIEW.md` 순서로 읽게 하면  
     프로젝트 전반(기획/기술/ML 흐름)을 빠르게 파악할 수 있다.

