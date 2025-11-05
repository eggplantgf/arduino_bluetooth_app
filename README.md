# Arduino 블루투스 앱

Arduino와 블루투스로 통신하는 Flutter 앱입니다.

## 개발 환경

- Flutter SDK 3.8.1 이상
- Dart 3.8.1 이상
- Android Studio 또는 Visual Studio Code
- Android 기기 (API 21 이상, Android 5.0 Lollipop 이상)

## 프로젝트 구조

```
arduino_bluetooth_app/
├── lib/
│   └── main.dart                    # 앱의 메인 코드 (모든 로직과 UI가 여기 있습니다)
├── android/
│   ├── app/
│   │   ├── build.gradle.kts         # Android 빌드 설정
│   │   └── src/main/
│   │       └── AndroidManifest.xml  # Android 권한 및 앱 설정
│   └── build.gradle.kts             # 프로젝트 전체 빌드 설정
├── pubspec.yaml                     # Flutter 패키지 의존성 관리
└── README.md
```

## 앱 실행 방법

### 1. Flutter 설치

Flutter SDK를 설치합니다: https://docs.flutter.dev/get-started/install

### 2. 의존성 설치

프로젝트 폴더에서 터미널을 열고 다음 명령어를 실행합니다:

```bash
flutter pub get
```

### 3. Android 기기 연결

- Android 스마트폰을 USB로 컴퓨터에 연결합니다
- 개발자 옵션을 활성화하고 USB 디버깅을 켭니다

### 4. 앱 실행

```bash
flutter run
```

## Java와 비교 설명

### Flutter의 위젯(Widget) 개념

- Flutter에서는 모든 UI 요소가 위젯입니다
- Java Android의 View, ViewGroup과 유사한 개념입니다
- 위젯들을 조합하여 화면을 만듭니다

### StatelessWidget vs StatefulWidget

```dart
// StatelessWidget: 변하지 않는 정적인 화면
// Java로 비유하면: final로 선언된 View

// StatefulWidget: 상태가 변할 수 있는 동적인 화면
// Java로 비유하면: 데이터가 변경되면 notifyDataSetChanged()를 호출하는 RecyclerView
```

### 비동기 프로그래밍 (async/await)

```dart
// Dart의 async/await는 Java의 CompletableFuture나 RxJava와 유사합니다
void example() async {
  var result = await someAsyncOperation();  // 작업이 완료될 때까지 대기
  print(result);
}

// Java로 비유하면:
// CompletableFuture.supplyAsync(() -> someOperation())
//   .thenAccept(result -> System.out.println(result));
```

### 상태 관리 (setState)

```dart
// setState()는 화면을 다시 그리도록 Flutter에게 알립니다
setState(() {
  counter = counter + 1;  // 변수 변경
});

// Java Android로 비유하면:
// counter++;
// textView.setText(String.valueOf(counter));  // 화면 업데이트
// 또는 adapter.notifyDataSetChanged();
```

## 주요 파일별 설명

### lib/main.dart

- 앱의 모든 로직과 UI가 들어있는 메인 파일입니다
- 각 함수와 위젯의 역할을 Java와 비교하여 설명합니다

### pubspec.yaml

- 프로젝트의 의존성을 관리하는 파일입니다
- Java의 pom.xml이나 build.gradle과 같은 역할입니다
- 사용할 라이브러리와 버전을 여기에 명시합니다

### android/app/src/main/AndroidManifest.xml

- Android 앱의 권한과 설정을 정의하는 파일입니다
- Java Android 개발과 동일한 형식입니다
- 블루투스 권한, 위치 권한 등이 선언되어 있습니다

### android/app/build.gradle.kts

- Android 앱의 빌드 설정 파일입니다
- minSdk, targetSdk 등을 설정합니다
- Java Android 프로젝트의 build.gradle과 동일한 역할입니다

## 참고 자료

### Flutter 공식 문서

- Flutter 시작하기: https://docs.flutter.dev/get-started/codelab
- Dart 언어 튜토리얼: https://dart.dev/tutorials

### Java 개발자를 위한 Flutter 가이드

- https://docs.flutter.dev/get-started/flutter-for/android-devs

### 블루투스 통신 이해하기

- BLE(Bluetooth Low Energy) 기초: https://www.arduino.cc/en/Reference/ArduinoBLE
