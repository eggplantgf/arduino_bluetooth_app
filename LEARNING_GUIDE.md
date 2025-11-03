# Arduino 블루투스 앱 학습 가이드

## 1. Flutter와 Java의 차이점

### 1.1 언어의 차이

#### Java

```java
public class Person {
    private String name;
    private int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public String getName() {
        return name;
    }
}
```

#### Dart (Flutter)

```dart
class Person {
  String name;
  int age;

  // 생성자가 훨씬 간단합니다
  Person(this.name, this.age);

  // getter는 자동으로 생성됩니다
  // person.name 으로 바로 접근 가능
}
```

### 1.2 UI 작성 방식의 차이

#### Java Android (XML + Java)

```xml
<!-- activity_main.xml -->
<LinearLayout>
    <TextView
        android:id="@+id/textView"
        android:text="Hello" />
    <Button
        android:id="@+id/button"
        android:text="Click" />
</LinearLayout>
```

```java
// MainActivity.java
TextView textView = findViewById(R.id.textView);
Button button = findViewById(R.id.button);
button.setOnClickListener(v -> {
    textView.setText("Clicked!");
});
```

#### Flutter (Dart 코드로 UI 작성)

```dart
// UI와 로직이 같은 파일에 있습니다
Column(
  children: [
    Text('Hello'),
    ElevatedButton(
      child: Text('Click'),
      onPressed: () {
        // 버튼 클릭 처리
      },
    ),
  ],
)
```

## 2. 이 프로젝트의 코드 흐름

### 2.1 앱 시작

```
main()
  → runApp(MyApp())
    → MaterialApp
      → BluetoothScreen (StatefulWidget)
        → BluetoothScreenState (State 클래스)
          → initState() 실행
            → 권한 요청
            → 블루투스 상태 확인
          → build() 실행 (UI 그리기)
```

### 2.2 블루투스 연결 과정

```
1. 사용자가 "블루투스 켜기" 버튼 클릭
   → turnOnBluetooth() 실행

2. 사용자가 "장치 찾기" 버튼 클릭
   → searchDevices() 실행
   → 10초 동안 검색
   → 찾은 장치들을 리스트에 저장
   → showDeviceList() 호출 (팝업 표시)

3. 사용자가 장치 선택
   → connectToDevice() 실행
   → 연결 성공 시 setupDataReceiving() 호출

4. 데이터 수신
   → characteristic.lastValueStream.listen()
   → 데이터가 올 때마다 자동으로 콜백 실행
   → showMessage()로 화면에 표시
```

### 2.3 상태 관리 흐름

```dart
// 사용자 액션
onPressed: () {
  // 1. setState() 호출
  setState(() {
    // 2. 변수 변경
    isSearching = true;
  });
}
// 3. Flutter가 자동으로 build() 메서드를 다시 호출
// 4. UI가 업데이트됨
```

## 3. Flutter의 위젯 시스템

### 3.1 StatelessWidget vs StatefulWidget

#### StatelessWidget (정적 위젯)

```dart
// 데이터가 변하지 않는 위젯
// Java로 비유하면: final 변수들만 있는 클래스
class WelcomeScreen extends StatelessWidget {
  final String userName;

  WelcomeScreen(this.userName);

  @override
  Widget build(BuildContext context) {
    return Text('Welcome, $userName');
  }
}
```

#### StatefulWidget (동적 위젯)

```dart
// 데이터가 변할 수 있는 위젯
// Java로 비유하면: notifyDataSetChanged()를 호출하는 RecyclerView
class Counter extends StatefulWidget {
  @override
  CounterState createState() => CounterState();
}

class CounterState extends State<Counter> {
  int count = 0;

  void increment() {
    setState(() {  // 화면을 다시 그립니다
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: increment,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

### 3.2 주요 레이아웃 위젯

#### Column (세로 배치)

```dart
// Java의 LinearLayout (vertical)과 동일
Column(
  children: [
    Text('First'),
    Text('Second'),
    Text('Third'),
  ],
)
```

#### Row (가로 배치)

```dart
// Java의 LinearLayout (horizontal)과 동일
Row(
  children: [
    Icon(Icons.star),
    Text('Rating'),
  ],
)
```

#### Container (박스)

```dart
// Java의 FrameLayout이나 View와 유사
Container(
  width: 100,
  height: 100,
  color: Colors.blue,
  padding: EdgeInsets.all(10),
  child: Text('Box'),
)
```

#### ListView (스크롤 리스트)

```dart
// Java의 RecyclerView와 유사
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index]),
    );
  },
)
```

## 4. 자주 사용하는 Dart 문법

### 4.1 변수 선언

```dart
// 타입 명시
String name = "John";
int age = 20;
bool isStudent = true;
List<String> items = ["A", "B", "C"];

// 타입 추론 (var)
var name = "John";  // String으로 자동 추론
var age = 20;  // int로 자동 추론

// 상수
final name = "John";  // 런타임 상수
const PI = 3.14;  // 컴파일 타임 상수
```

### 4.2 문자열

```dart
String name = "John";

// 문자열 보간
print("Hello, $name");  // Hello, John
print("Age: ${age + 1}");  // 표현식은 {}로 감싸기

// 멀티라인 문자열
String text = """
여러 줄에
걸친 문자열
""";
```

### 4.3 컬렉션

```dart
// List (Java의 ArrayList)
List<String> names = ["John", "Jane", "Bob"];
names.add("Alice");
print(names[0]);  // John
print(names.length);  // 4

// Map (Java의 HashMap)
Map<String, int> ages = {
  "John": 20,
  "Jane": 22,
};
ages["Bob"] = 21;
print(ages["John"]);  // 20

// Set (Java의 HashSet)
Set<String> unique = {"A", "B", "C"};
unique.add("A");  // 중복은 무시됨
```

### 4.4 함수

```dart
// 기본 함수
String greet(String name) {
  return "Hello, $name";
}

// 화살표 함수 (한 줄)
String greet(String name) => "Hello, $name";

// 선택적 매개변수
void printInfo(String name, [int? age]) {
  print("Name: $name");
  if (age != null) {
    print("Age: $age");
  }
}
printInfo("John");  // age 생략 가능
printInfo("Jane", 22);  // age 포함

// 이름 있는 매개변수
void printInfo({required String name, int? age}) {
  // ...
}
printInfo(name: "John");  // 이름을 명시해서 전달
printInfo(name: "Jane", age: 22);
```

### 4.5 클래스

```dart
class Person {
  String name;
  int age;

  // 생성자
  Person(this.name, this.age);

  // 이름 있는 생성자
  Person.guest() : name = "Guest", age = 0;

  // 메서드
  void introduce() {
    print("I'm $name, $age years old");
  }

  // Getter
  bool get isAdult => age >= 18;

  // Setter
  set setAge(int value) {
    if (value > 0) age = value;
  }
}

// 사용
var person = Person("John", 20);
person.introduce();
print(person.isAdult);
```

## 추가 학습 자료

### 공식 문서

- Dart 언어 투어: https://dart.dev/guides/language/language-tour
- Flutter 위젯 카탈로그: https://docs.flutter.dev/ui/widgets
- Flutter Cookbook: https://docs.flutter.dev/cookbook

### 온라인 강의

- Flutter 공식 튜토리얼: https://docs.flutter.dev/get-started/codelab
- Dart 기초 강의: https://dart.dev/tutorials

### 유용한 패키지

- provider: 상태 관리 (Java의 ViewModel과 유사)
- dio: HTTP 통신 (Java의 Retrofit과 유사)
- shared_preferences: 로컬 저장소 (Java의 SharedPreferences와 동일)
- sqflite: SQLite 데이터베이스
