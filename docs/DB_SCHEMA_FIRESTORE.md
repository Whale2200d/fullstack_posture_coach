## Posture Coach – Firestore 데이터베이스 스키마 (Commit 7)

MVP 단계에서 사용할 **Firestore 컬렉션/문서 구조**를 JSON 형태로 스케치한 문서입니다.  
실제 구현 시 필요에 따라 필드를 추가/수정할 수 있습니다.

---

## 1. 최상위 컬렉션 개요

```text
users/{userId}
coaches/{coachId}
sessions/{sessionId}
feedback/{feedbackId}
ml_labels/{labelId}
exercise_types/{exerciseTypeId}
```

---

## 2. users – 사용자 정보

컬렉션 경로: `users/{userId}`

```json
{
  "uid": "user_abc123",           // Firebase Auth UID
  "email": "user@example.com",
  "displayName": "홍길동",
  "role": "user",                 // "user" | "coach" | "admin"
  "createdAt": "<Timestamp>",
  "updatedAt": "<Timestamp>",

  "profile": {
    "heightCm": 180,
    "weightKg": 78,
    "age": 29,
    "gender": "male",             // optional
    "trainingLevel": "intermediate" // "beginner" | "intermediate" | "advanced"
  },

  "settings": {
    "language": "ko",
    "notificationsEnabled": true,
    "voiceFeedbackEnabled": true
  }
}
```

---

## 3. coaches – 코치/관리자 정보

컬렉션 경로: `coaches/{coachId}`

```json
{
  "uid": "coach_123",
  "email": "coach@example.com",
  "displayName": "코치 김",
  "createdAt": "<Timestamp>",
  "updatedAt": "<Timestamp>",

  "bio": "크로스 트레이닝 지도자",
  "specialties": ["squat", "deadlift", "yoga"]
}
```

> 간단한 경우에는 `users` 컬렉션의 `role` 필드만으로 코치를 구분하고, `coaches` 컬렉션은 선택 사항으로 둘 수 있습니다.

---

## 4. exercise_types – 운동 타입 정의

컬렉션 경로: `exercise_types/{exerciseTypeId}`

```json
{
  "id": "squat",
  "name": "스쿼트",
  "category": "cross_training",      // "cross_training" | "yoga" | "strength" ...
  "description": "하체 위주 복합 운동",
  "isActive": true,

  "defaultPoseConfig": {
    "model": "mediapipe_pose_lite",
    "targetJoints": ["hip", "knee", "ankle", "spine"],
    "angleThresholds": {
      "kneeFlexionMin": 80,
      "kneeFlexionMax": 120
    }
  }
}
```

이 컬렉션을 기반으로 앱의 운동 타입 enum을 구성하고,  
추후 요가/웨이트 등 새로운 운동을 추가할 수 있습니다.

---

## 5. sessions – 운동 세션 / 영상

컬렉션 경로: `sessions/{sessionId}`

```json
{
  "id": "session_20260310_001",
  "userId": "user_abc123",
  "exerciseTypeId": "squat",

  "device": {
    "platform": "ios",              // "ios" | "android" | "web" | "macos"
    "model": "iPhone 16e"
  },

  "video": {
    "storagePath": "users/user_abc123/sessions/session_20260310_001/video.mp4",
    "downloadUrl": "https://firebasestorage.googleapis.com/...",
    "durationSec": 18.5,
    "resolution": "1080x1920",
    "fps": 30
  },

  "analysis": {
    "model": "mediapipe_pose_lite",
    "processedAt": "<Timestamp>",
    "summary": {
      "overallScore": 3.8,          // 1~5, 규칙 기반 초기 점수
      "keyIssues": ["back_round", "knee_forward"]
    }
  },

  "createdAt": "<Timestamp>",
  "updatedAt": "<Timestamp>"
}
```

> 실제로는 `users/{userId}/sessions/{sessionId}` 처럼 **users 하위 서브컬렉션**으로 둘 수도 있습니다.  
> 조회 패턴(코치가 전체 세션을 훑는지, 사용자별로만 보는지)에 따라 구조를 선택합니다.

---

## 6. feedback – 코치 피드백

컬렉션 경로: `feedback/{feedbackId}`

```json
{
  "id": "feedback_001",
  "sessionId": "session_20260310_001",
  "userId": "user_abc123",
  "coachId": "coach_123",

  "label": {
    "isPositive": false,          // 좋아요/싫어요
    "score": 2,                   // 1~5 단계 슬라이더 값
    "comments": "허리 말림이 심해서 하중 줄이세요."
  },

  "timeRange": {
    "startSec": 4.2,
    "endSec": 7.8
  },

  "createdAt": "<Timestamp>"
}
```

> 단순화된 경우에는 `sessions/{sessionId}/feedback/{feedbackId}` 형태의 서브컬렉션으로 둘 수 있습니다.

---

## 7. ml_labels – ML 재학습용 라벨 데이터

컬렉션 경로: `ml_labels/{labelId}`

```json
{
  "id": "label_001",
  "sessionId": "session_20260310_001",
  "userId": "user_abc123",
  "coachId": "coach_123",
  "exerciseTypeId": "squat",

  // 모델 입력으로 사용될 피쳐(요약 랜드마크/각도 등)
  "features": {
    "jointAngles": {
      "kneeLeftMin": 75.3,
      "kneeLeftMax": 118.2,
      "backForwardMax": 22.5
    },
    "tempo": {
      "eccentricSec": 2.1,
      "concentricSec": 1.0
    }
  },

  // 타깃 라벨: 코치 피드백 기반
  "target": {
    "label": "bad_posture",     // "good_posture" | "bad_posture" ...
    "score": 2                  // 1~5
  },

  "createdAt": "<Timestamp>"
}
```

이 컬렉션은 Cloud Functions 또는 별도 학습 파이프라인(TensorFlow, PyTorch 등)에서  
주기적으로 읽어서 모델 재학습에 사용합니다.

---

## 8. 설계 메모

- **정규화 vs 중복**  
  - 조회 빈도가 높은 필드(예: 사용자 이름, 운동 타입 이름)는 상위 컬렉션과 세션/피드백 문서에 일부 중복 저장할 수 있습니다.
  - Firestore는 조인이 없기 때문에, 읽기 편의를 위해 적절한 중복을 허용합니다.

- **서브컬렉션 사용 여부**  
  - 간단히 시작하려면 위처럼 **최상위 컬렉션 구조**로 두고,
  - 나중에 필요하면 `users/{userId}/sessions/...` 처럼 중첩 구조로 리팩토링할 수 있습니다.

- **보안 규칙**  
  - `users/{userId}` 문서는 본인만 읽기/수정 가능.
  - `sessions` 는 본인 + 권한 있는 코치만 읽기.
  - `feedback`, `ml_labels`는 코치/시스템만 작성, 사용자는 요약 정보만 읽을 수 있도록 규칙을 설계합니다.

