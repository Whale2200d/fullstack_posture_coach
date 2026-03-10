## Firebase 기본 설정 (Commit 3)

이 문서는 **Posture Coach** 앱을 Firebase에 연결하기 위한 최소 설정을 정리합니다.
Firebase 프로젝트 이름/ID에는 **`crossfit` 단어를 넣지 않습니다.**

---

### 1. Firebase 프로젝트 생성 (콘솔)

1. 브라우저에서 `https://console.firebase.google.com` 접속
2. **프로젝트 추가(Add project)** 클릭
3. 프로젝트 이름 예시 (원하는 이름으로, 단 `crossfit`은 제외):
   - `posture-coach-app`
   - `posture-coach-lab`
   - `posture-coach-prod` 등
4. 프로젝트 ID도 자동으로 생성되는데, 가능하면 `posture-coach-...` 처럼 일반적인 이름으로 둡니다.
5. Google Analytics는 **원하면 켜고**, 아니면 꺼도 됩니다(나중에 켤 수 있음).
6. 프로젝트 생성이 끝날 때까지 기다립니다.

---

### 2. 앱 등록 (iOS / Android / Web)

Firebase 콘솔의 새 프로젝트 화면에서:

#### 2-1. iOS 앱 등록

1. iOS 아이콘(애플 로고)을 클릭합니다.
2. **iOS 번들 ID**에 Xcode/Flutter 프로젝트의 번들 ID를 입력합니다. 기본 생성값은 대략:
   - `com.crossfit.posturecoach.postureCoach` 또는 비슷한 형태일 수 있습니다.
   - 정확한 값은 `ios/Runner.xcodeproj` → Runner 대상의 **Bundle Identifier**를 확인해서 사용합니다.
3. 앱 닉네임은 자유롭게 입력 (예: `Posture Coach iOS`).
4. 다음 단계를 눌러 `GoogleService-Info.plist` 파일을 다운로드합니다.
5. 이 파일은 **Git에 커밋하지 말고**, 로컬에서만 사용합니다. (이미 `.gitignore`에 예외가 설정되어 있음)
6. Xcode에서 iOS 앱에 연결:
   - `ios/Runner` 폴더에 `GoogleService-Info.plist` 를 추가 (Xcode에서 드래그 앤 드롭 → “Copy items if needed” 체크).

#### 2-2. Android 앱 등록

1. Firebase 콘솔에서 Android 아이콘 클릭.
2. **Android 패키지 이름**에는 `android/app/src/main/AndroidManifest.xml` 의 `package` 값을 입력합니다.
   - Flutter `--org` 옵션을 `com.crossfit.posturecoach` 로 생성했다면:
     - 패키지 이름은 보통 `com.crossfit.posturecoach.posture_coach` 형태입니다.
3. 앱 닉네임은 자유롭게 (예: `Posture Coach Android`).
4. 안내에 따라 `google-services.json` 파일을 다운로드합니다.
5. 이 파일도 **Git에 커밋하지 않고**, 로컬에서만 사용합니다. (`.gitignore`에 이미 추가됨)
6. 파일을 `android/app/google-services.json` 경로에 복사합니다.
7. `android/build.gradle` 및 `android/app/build.gradle` 에 Google Services 플러그인을 추가해야 합니다.  
   (이 부분은 추후 Commit에서 자동/반자동으로 정리할 예정입니다. 현재 Commit 3에서는 콘솔/파일 준비까지만 진행해도 됩니다.)

#### 2-3. Web 앱 등록 (선택)

1. Firebase 콘솔에서 Web 아이콘(</>) 클릭.
2. 앱 닉네임 입력 (예: `Posture Coach Web`).
3. `firebaseConfig` 자바스크립트 설정이 화면에 표시됩니다.
4. 이 설정은 이후 `flutterfire configure` 를 사용할 때 Flutter 쪽으로 자동 반영할 수 있으므로,
   현재는 **프로젝트에 기록하지 않고** 콘솔에서만 확인해 두어도 됩니다.

---

### 3. Flutter 앱에서 Firebase 초기화 방식

현재 `lib/main.dart` 에는 다음과 같이 Firebase를 초기화하도록 코드가 작성되어 있습니다.

- **웹이 아닌 플랫폼(iOS/Android/macOS/Windows)** 에서만 기본 설정으로 `Firebase.initializeApp()` 을 호출
- 웹은 추후 `flutterfire configure` 완료 후 `DefaultFirebaseOptions.currentPlatform` 을 사용해 초기화 예정

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }

  runApp(const PostureCoachApp());
}
```

즉:
- **iOS / Android**: `GoogleService-Info.plist` / `google-services.json` 를 각각 프로젝트에 넣어주기만 하면,
  위 코드로 Firebase가 자동 연결됩니다.
- **웹**: 추후 `flutterfire configure` 를 통해 생성되는 `firebase_options.dart` 를 사용해 별도로 초기화할 예정입니다.

---

### 4. Firebase 연결 테스트

1. iOS 시뮬레이터 또는 Android 에뮬레이터를 켭니다.
2. 프로젝트 루트에서:

```bash
cd /Users/imgyeonglak/Documents/01_career/01_dev_project/03_FullStack/03_Posture_Coach
flutter run -d <iOS_또는_Android_기기ID>
```

3. 앱이 실행되고, 콘솔 로그(터미널)에 에러 없이 올라오면 기본 초기화는 성공입니다.
   - 만약 `Firebase initialization failed` 로그가 뜨면:
     - 해당 플랫폼의 설정 파일이 올바른 위치에 있는지 (`GoogleService-Info.plist`, `google-services.json`)
     - Bundle ID / 패키지 이름이 Firebase 콘솔에 등록한 값과 일치하는지 확인합니다.

---

### 5. 다음 단계 예고

이후 Commit에서 아래 작업을 이어갈 예정입니다.

- `firebase_auth`, `cloud_firestore`, `firebase_storage` 등의 패키지 추가
- FlutterFire CLI(`flutterfire configure`)를 사용한 웹 포함 멀티플랫폼 설정
- Cloud Functions 및 ML 재학습 파이프라인과의 연동

## Firebase 프로젝트 생성 및 기본 설정 (Commit 3)

이 문서는 Posture Coach 앱을 Firebase와 연결하는 방법을 정리한 것입니다.

---

### 1. Firebase 콘솔에서 프로젝트 생성

1. 브라우저에서 `https://console.firebase.google.com` 접속
2. **프로젝트 추가** 클릭
3. 프로젝트 이름 예시: `posture-coach`
4. Google Analytics는 **원하는 대로** (초기에는 꺼둬도 됨)
5. 생성이 끝날 때까지 기다린다.

---

### 2. Flutter 앱과 Firebase 프로젝트 연결 (요약)

각 플랫폼(iOS / Android / Web)에 대해 Firebase 콘솔에서 “앱 추가”를 하고, Flutter에서는 `firebase_core`를 통해 초기화합니다.

#### 2-1. Android 앱 등록

1. Firebase 콘솔 → 방금 만든 프로젝트 → **Android 아이콘** 클릭
2. **Android 패키지 이름** 입력:
   - 예: `com.posturecoach.posture_coach`
   - 실제 값은 `android/app/src/main/AndroidManifest.xml` 의 `package` 와 동일해야 함
3. 앱 닉네임은 자유롭게 입력 (예: `Posture Coach Android`)
4. 지시에 따라 `google-services.json` 파일을 다운로드
5. Flutter 프로젝트의 `android/app/` 폴더에 `google-services.json` 저장  
   (이 파일은 `.gitignore` 에 의해 Git에 포함되지 않습니다.)
6. Firebase 콘솔 안내대로 `android/build.gradle`, `android/app/build.gradle` 의 `google-services` 플러그인 설정을 확인/추가

#### 2-2. iOS 앱 등록

1. Firebase 콘솔에서 **iOS 아이콘** 클릭
2. iOS 번들 ID 입력:
   - 예: `com.posturecoach.postureCoach`
   - 실제 값은 `ios/Runner.xcodeproj` / `ios/Runner/Info.plist` 의 `PRODUCT_BUNDLE_IDENTIFIER` 와 동일해야 함
3. 지시에 따라 `GoogleService-Info.plist` 파일 다운로드
4. Flutter 프로젝트의 `ios/Runner/` 폴더에 `GoogleService-Info.plist` 저장  
   (이 파일도 `.gitignore` 에 의해 Git에 포함되지 않습니다.)

#### 2-3. Web 앱 등록(원할 때)

1. Firebase 콘솔에서 **웹 아이콘(</>)** 클릭
2. 앱 닉네임 입력 (예: `posture-coach-web`)
3. 생성 후 나오는 `firebaseConfig` 값을 복사해둔다.
4. 나중에 `web/index.html` 혹은 `firebase_options.dart` 에서 사용하게 된다.

---

### 3. Flutter 코드에서 Firebase 초기화

`pubspec.yaml` 에는 이미 다음 의존성이 추가되어 있습니다.

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`

`lib/main.dart` 에서는 다음과 같이 Firebase를 초기화합니다.

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PostureCoachApp());
}
```

> ⚠️ 주의:  
> - Android: `google-services.json` 이 `android/app/` 에 있어야 합니다.  
> - iOS: `GoogleService-Info.plist` 가 `ios/Runner/` 에 있어야 합니다.  
> - Web: 이후에 `firebase_options.dart` 또는 웹 초기화 코드가 필요합니다.

---

### 4. FlutterFire CLI(선택 사항, 멀티플랫폼에서 권장)

웹까지 포함해 모든 플랫폼에서 같은 코드로 Firebase를 초기화하고 싶다면, FlutterFire CLI를 사용해 `firebase_options.dart` 를 생성할 수 있습니다.

1. 설치

```bash
dart pub global activate flutterfire_cli
```

2. 프로젝트 루트에서 실행

```bash
cd /Users/imgyeonglak/Documents/01_career/01_dev_project/03_FullStack/03_Posture_Coach
flutterfire configure
```

3. 마법사의 안내에 따라 Firebase 프로젝트와 사용할 플랫폼(iOS, Android, Web 등)을 선택하면,  
   `lib/firebase_options.dart` 파일이 자동으로 생성됩니다.

4. 생성 후에는 `main.dart` 의 초기화 코드를 다음과 같이 바꾸면 됩니다.

```dart
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PostureCoachApp());
}
```

이 방식은 **한 줄의 코드로 모든 플랫폼에서 올바른 Firebase 설정**을 사용하게 해 줍니다.

---

### 5. 연결 테스트

1. `flutter pub get` 실행
2. 원하는 기기에서 앱 실행:

```bash
flutter run -d macos
# 또는
flutter run -d chrome
# 또는
flutter run -d <emulator-5554 / iPhone_UDID 등>
```

3. 앱이 정상적으로 시작되고 콘솔에 Firebase 관련 에러가 없다면,  
   **Firebase 기본 연결이 완료된 것**입니다.

