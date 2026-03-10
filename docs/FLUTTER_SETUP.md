# Flutter 환경 세팅 (Commit 2)

---

## ① 처음부터 RUN·TEST 하기 (이것만 따라하면 됨)

**이미 Flutter를 설치했다면** 아래 3단계만 하면 됩니다.

### 1단계: 프로젝트 폴더로 이동

```bash
cd /Users/imgyeonglak/Documents/01_career/01_dev_project/03_FullStack/03_Posture_Coach
```

### 2단계: 플랫폼 코드 생성 (최초 1번만)

지금 프로젝트에는 **앱 화면 코드**(`lib/main.dart`)만 있고, **안드로이드·iOS용 빌드 폴더**(`android`/`ios`)는 없습니다.  
그래서 `flutter create .`를 한 번 실행해서 그 폴더들을 만들어 줘야 합니다.

- **실행:** 아래 명령을 그대로 입력하고 엔터.
- **"Overwrite lib/main.dart?"** 라고 나오면 → **n** 입력 후 엔터.  
  (우리가 만든 화면 코드를 유지하려는 뜻입니다. **y**를 누르면 Flutter 기본 예제로 바뀝니다.)

```bash
flutter create . --project-name posture_coach --org com.crossfit.posturecoach
```

### 3단계: 실행 또는 테스트

**의존성 받기 (최초 1번 또는 pubspec 수정 후):**

```bash
flutter pub get
```

**앱 실행 (Chrome 또는 macOS 중 하나):**

```bash
flutter run -d chrome
```

또는

```bash
flutter run -d macos
```

**테스트 실행:**

```bash
flutter test
```

---

정리하면, **매번 할 일**은 다음만 기억하면 됩니다.

| 하고 싶은 것 | 명령어 |
|-------------|--------|
| 앱 실행 (웹) | `flutter run -d chrome` |
| 앱 실행 (맥 앱) | `flutter run -d macos` |
| 앱 실행 (Android) | `flutter run -d <android_기기ID>` |
| 앱 실행 (iOS) | `flutter run -d <ios_기기ID>` |
| 테스트 실행 | `flutter test` |

---

## ② 실행하기 (기기별, 순서대로)

아래는 **“실제로 앱을 띄우는”** 절차만 모아둔 것입니다. (설정이 안 되어 있으면 ③을 먼저 진행)

### A. iPhone (iOS 시뮬레이터)에서 실행

1. 시뮬레이터 실행

```bash
open -a Simulator
```

2. 기기 목록 확인 (iPhone 16e 같은 기기가 보여야 함)

```bash
flutter devices
```

3. iPhone 16e(원하는 iPhone)로 실행  
`flutter devices` 출력에서 iPhone 옆 **ID(UDID)** 를 복사해서 아래에 붙여넣습니다.

```bash
cd /Users/imgyeonglak/Documents/01_career/01_dev_project/03_FullStack/03_Posture_Coach
flutter run -d <iPhone_UDID>
```

### B. Android (에뮬레이터)에서 실행

1. Android Studio에서 에뮬레이터(AVD) 실행  
Device Manager에서 원하는 기기 옆 **▶(재생)** 을 눌러 켭니다.

2. 기기 목록 확인 (emulator-5554 같은 게 보여야 함)

```bash
flutter devices
```

3. 실행 (에뮬레이터가 1개만 켜져 있으면 자동으로 잡힘)

```bash
cd /Users/imgyeonglak/Documents/01_career/01_dev_project/03_FullStack/03_Posture_Coach
flutter run
```

여러 기기가 있으면 `flutter run -d <android_기기ID>` 로 지정 실행합니다.

### C. macOS(데스크톱)에서 실행

```bash
cd /Users/imgyeonglak/Documents/01_career/01_dev_project/03_FullStack/03_Posture_Coach
flutter run -d macos
```

### D. Chrome(웹)에서 실행

```bash
cd /Users/imgyeonglak/Documents/01_career/01_dev_project/03_FullStack/03_Posture_Coach
flutter run -d chrome
```

---

## ② Flutter가 아직 없다면 (설치)

1. 설치 (macOS):

   ```bash
   brew install --cask flutter
   ```

2. 터미널을 **한 번 닫았다가 다시 연다**.

3. 환경 확인:

   ```bash
   flutter doctor -v
   ```

4. **Flutter** 줄에 ✓ 나오면 위 **1단계 ~ 3단계**로 가서 RUN/TEST 하면 됩니다.  
   Android·Xcode에 ✗가 있어도 **Chrome / macOS**로는 이미 실행 가능합니다.

---

## ③ (설정) 모바일(Android·iOS)에서 돌려보고 싶을 때

위 ②에서 실행이 안 될 때, 아래를 **번호 순서대로** 그대로 따라하면 됩니다.

---

### A. Android 에뮬레이터에서 실행하기

#### 1단계: Android SDK Command-line Tools 설치 (한 번만)

1. **Android Studio**를 연다.
2. **환경에 따라 둘 중 하나:**
   - **처음 켰을 때(프로젝트 없이):** 화면 오른쪽 위 **⋮ (세 점)** 또는 **More Actions** 클릭 → **SDK Manager** 클릭.
   - **프로젝트 열려 있을 때:** 상단 메뉴 **Tools** → **SDK Manager** 클릭.
3. **SDK Manager** 창이 뜨면 위쪽 탭에서 **SDK Tools** 를 클릭한다.
4. 목록에서 **Android SDK Command-line Tools (latest)** 에 체크가 있는지 확인한다. 없으면 체크한다.
5. 오른쪽 아래 **Apply** (또는 **OK**) 클릭 → 필요하면 **OK**로 설치 완료까지 기다린다.
6. **Finish** 등으로 창을 닫는다.

#### 2단계: Android 라이선스 동의 (한 번만)

1. **터미널**을 연다.
2. 아래 명령을 **그대로 붙여넣고** 엔터:

   ```bash
   flutter doctor --android-licenses
   ```

3. `y/n` 이 나올 때마다 **y** 입력 후 엔터. 끝날 때까지 반복한다.

#### 3단계: 에뮬레이터 만들기 (이미 있으면 건너뛰기)

1. **Android Studio**에서:
   - **⋮ (세 점)** 또는 **More Actions** → **Virtual Device Manager** 클릭.
   - 또는 **Tools** → **Device Manager**.
2. **Create Device** (또는 **+** 버튼) 클릭.
3. **Phone** 카테고리에서 기기 하나 선택 (예: **Pixel 6**) → **Next**.
4. **Recommended** 탭에서 시스템 이미지 하나 선택 (예: **Tiramisu**, API 33). 옆에 **Download** 가 있으면 클릭해 받은 뒤 선택 → **Next**.
5. **Finish** 클릭.

#### 4단계: 에뮬레이터 켜고 앱 실행

1. **Virtual Device Manager** 목록에서 방금 만든 기기 옆 **▶ (재생 버튼)** 클릭 → 에뮬레이터가 부팅될 때까지 기다린다.
2. **터미널**에서 아래 두 줄을 **순서대로** 실행:

   ```bash
   cd /Users/imgyeonglak/Documents/01_career/01_dev_project/03_FullStack/03_Posture_Coach
   flutter run
   ```

3. 에뮬레이터가 하나만 켜져 있으면 자동으로 그 기기에 앱이 설치·실행된다.  
   기기가 여러 개면 `flutter devices` 로 ID를 확인한 뒤 `flutter run -d <기기ID>` 로 지정해서 실행한다.

---

### B. iOS 시뮬레이터에서 실행하기 (Mac만)

#### 1단계: CocoaPods 설치/재설치 (flutter doctor에서 CocoaPods 오류가 났을 때만)

1. **터미널**을 연다.
2. 아래 명령을 붙여넣고 엔터:

   ```bash
   sudo gem install cocoapods
   ```

3. **Password:** 라고 나오면 Mac 로그인 비밀번호 입력 후 엔터 (화면에는 안 보여도 입력됨).
4. 설치가 끝날 때까지 기다린다.

#### 2단계: iOS 시뮬레이터 켜기

1. **방법 1:** 키보드에서 **⌘ + Space** 눌러 Spotlight 띄운 뒤 **Simulator** 입력 → **Simulator** 앱 더블클릭.
2. **방법 2:** **Xcode** 실행 → 상단 메뉴 **Xcode** → **Open Developer Tool** → **Simulator** 클릭.
3. iPhone이 보이는 시뮬레이터 창이 뜨면 그대로 둔다.

#### 3단계: 앱 실행

1. **터미널**에서 아래 두 줄을 **순서대로** 실행:

   ```bash
   cd /Users/imgyeonglak/Documents/01_career/01_dev_project/03_FullStack/03_Posture_Coach
   flutter run
   ```

2. iOS 시뮬레이터가 켜져 있으면 그 기기로 앱이 설치·실행된다.  
   기기가 여러 개면 `flutter devices` 로 ID 확인 후 `flutter run -d <기기ID>` 로 실행한다.

---

### 기기 목록 확인 (실행할 기기를 골라야 할 때)

터미널에서:

```bash
flutter devices
```

나온 목록에서 사용할 기기의 **ID**(예: `sdk gphone64 arm64`)를 복사한 뒤:

```bash
flutter run -d <여기에_ID_붙여넣기>
```

예: `flutter run -d sdk gphone64 arm64`

---

## ④ 에디터 (VSCode / Cursor)

VSCode나 Cursor에서 작업해도 됩니다.  
**Flutter**, **Dart** 확장만 설치하면 됩니다.
