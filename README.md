# Posture Coach (Flutter)

카메라 기반 자세 분석으로 크로스 트레이닝(스쿼트, 데드리프트 등) 동작을 교정하는 모바일/웹 앱입니다.  
초기 버전은 Flutter + Firebase 기반으로 iOS/Android/웹(Chrome, macOS 데스크톱)을 모두 지원하는 것을 목표로 합니다.

---

## 실행 방법 (요약)

자세한 내용은 `docs/FLUTTER_SETUP.md` 를 참고하세요.

```bash
cd /Users/imgyeonglak/Documents/01_career/01_dev_project/03_FullStack/03_Posture_Coach

# 웹
flutter run -d chrome

# macOS 데스크톱
flutter run -d macos

# Android 에뮬레이터 (예: emulator-5554)
flutter run -d emulator-5554

# iOS 시뮬레이터 (예: iPhone 16e UDID)
flutter run -d <iPhone_UDID>
```

---

## Firebase 기본 설정

Commit 3에서 Firebase와의 최소 연동을 위한 준비를 합니다.

- Firebase 프로젝트 이름/ID에는 **`crossfit` 단어를 사용하지 않습니다.**
- iOS / Android 앱을 Firebase 콘솔에 등록하고,
  - `GoogleService-Info.plist` (iOS)
  - `google-services.json` (Android)
  파일을 각각 플랫폼 프로젝트에 추가합니다. (Git에는 커밋하지 않음)
- Flutter 앱에서는 `firebase_core` 를 이용해 기본 초기화를 수행합니다.

자세한 절차는 `docs/FIREBASE_SETUP.md` 를 참고하세요.

---

## 문서

- `docs/FLUTTER_SETUP.md` – Flutter SDK 설치, 시뮬레이터/에뮬레이터 실행, 각 플랫폼별 실행 방법
- `docs/FIREBASE_SETUP.md` – Firebase 프로젝트 생성 및 iOS/Android 연결 가이드
