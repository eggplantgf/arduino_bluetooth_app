// 필요한 라이브러리 불러오기 (Java의 import와 동일)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// 프로그램 시작점 (Java의 main 메서드)
void main() {
  runApp(MyApp());
}

// 앱의 최상위 클래스
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Arduino 블루투스', home: BluetoothScreen());
  }
}

// 블루투스 화면
// StatefulWidget = 상태가 변하는 동적 위젯
class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  BluetoothScreenState createState() => BluetoothScreenState();
}

// 블루투스 화면의 상태와 로직을 관리하는 클래스
class BluetoothScreenState extends State<BluetoothScreen> {
  // 멤버 변수들 (Java의 필드)
  BluetoothDevice? connectedDevice; // ? = null 허용
  List<String> messages = []; // Java의 ArrayList<String>
  bool isBluetoothOn = false;
  bool isSearching = false;
  List<BluetoothDevice> foundDevices = [];

  // 위젯 생성 시 한 번만 실행됨
  @override
  void initState() {
    super.initState();
    askPermissions();
    checkBluetoothStatus();
  }

  // === 권한 요청 ===
  void askPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request(); // Android는 블루투스 검색 시 위치 권한 필요
  }

  // === 블루투스 상태 확인 ===
  void checkBluetoothStatus() async {
    var state = await FlutterBluePlus.adapterState.first;
    setState(() {
      // setState로 화면 업데이트 (Java의 notifyDataSetChanged 역할)
      isBluetoothOn = (state == BluetoothAdapterState.on);
    });
  }

  // === 블루투스 켜기 ===
  void turnOnBluetooth() async {
    if (!isBluetoothOn) {
      await FlutterBluePlus.turnOn();
      checkBluetoothStatus();
    }
  }

  // === 장치 검색 ===
  // 1. 10초 동안 주변 블루투스 장치 검색
  // 2. 찾은 장치들을 foundDevices 리스트에 저장
  // 3. 검색 완료 후 장치 목록 팝업 표시
  void searchDevices() async {
    if (!isBluetoothOn) {
      showMessage("먼저 블루투스를 켜주세요!");
      return;
    }

    setState(() {
      isSearching = true;
      foundDevices.clear();
    });

    showMessage("장치를 찾는 중...");

    // 10초 동안 스캔
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

    // 검색 결과를 계속 받아서 리스트에 저장
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        foundDevices = results.map((r) => r.device).toList();
      });
    });

    await Future.delayed(Duration(seconds: 10));
    await FlutterBluePlus.stopScan();

    setState(() {
      isSearching = false;
    });

    if (foundDevices.isNotEmpty) {
      showDeviceList();
    } else {
      showMessage("장치를 찾을 수 없습니다.");
    }
  }

  // === 장치 선택 팝업 ===
  void showDeviceList() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('장치 선택'),
          content: SizedBox(
            width: 300,
            height: 300,
            // ListView.builder = Java의 RecyclerView
            child: ListView.builder(
              itemCount: foundDevices.length,
              itemBuilder: (context, index) {
                var device = foundDevices[index];
                String deviceName = device.platformName.isEmpty
                    ? "알 수 없는 장치"
                    : device.platformName;

                return ListTile(
                  title: Text(deviceName),
                  subtitle: Text(device.remoteId.toString()),
                  onTap: () {
                    Navigator.pop(context); // 팝업 닫기
                    connectToDevice(device);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // === 장치 연결 ===
  // 1. 선택한 장치에 연결 시도
  // 2. 연결 성공 시 데이터 수신 설정
  void connectToDevice(BluetoothDevice device) async {
    showMessage("${device.platformName}에 연결 중...");

    try {
      await device.connect();
      setState(() {
        connectedDevice = device;
      });
      showMessage("연결 성공!");

      setupDataReceiving(device);
    } catch (e) {
      showMessage("연결 실패: $e");
    }
  }

  // === 데이터 수신 설정 ===
  // 블루투스 GATT 프로토콜 사용
  // 1. 장치의 서비스(Service)들을 검색
  // 2. 각 서비스의 특성(Characteristic) 검색
  // 3. notify 속성이 있는 특성을 찾아서 활성화
  // 4. 데이터가 올 때마다 자동으로 콜백 실행
  void setupDataReceiving(BluetoothDevice device) async {
    try {
      var services = await device.discoverServices();

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          // notify = 데이터 변경 시 자동 알림
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);

            // 데이터 수신 리스너 등록 (Java의 Observable.subscribe와 유사)
            characteristic.lastValueStream.listen((data) {
              if (data.isNotEmpty) {
                // 바이트 배열 -> 문자열 변환
                String message = utf8.decode(data).trim();
                if (message.isNotEmpty) {
                  showMessage("받음: $message");
                }
              }
            });

            showMessage("데이터 받기 준비 완료!");
            return;
          }
        }
      }
    } catch (e) {
      showMessage("데이터 받기 설정 실패: $e");
    }
  }

  // === 연결 끊기 ===
  void disconnect() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect(); // ! = null이 아님을 확신
      setState(() {
        connectedDevice = null;
      });
      showMessage("연결 끊김");
    }
  }

  // === 메시지 추가 ===
  void showMessage(String message) {
    setState(() {
      messages.add(message);
    });
  }

  // === 메시지 전체 삭제 ===
  void clearMessages() {
    setState(() {
      messages.clear();
    });
  }

  // === UI 구성 ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 바
      appBar: AppBar(
        title: Text('Arduino 블루투스'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // 본문
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          // 세로 배치 (Java의 LinearLayout vertical)
          children: [
            // === 상태 표시 영역 ===
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '블루투스: ${isBluetoothOn ? "켜짐" : "꺼짐"}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    connectedDevice != null
                        ? '연결됨: ${connectedDevice!.platformName}'
                        : '연결 안됨',
                    style: TextStyle(
                      fontSize: 16,
                      color: connectedDevice != null
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // === 버튼 영역 ===
            Row(
              // 가로 배치 (Java의 LinearLayout horizontal)
              children: [
                // 블루투스 켜기 버튼 (블루투스 꺼져있을 때만 표시)
                if (!isBluetoothOn)
                  Expanded(
                    // Expanded = 남은 공간 채움 (layout_weight와 유사)
                    child: ElevatedButton(
                      onPressed: turnOnBluetooth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(16),
                      ),
                      child: Text('블루투스 켜기'),
                    ),
                  ),

                // 장치 찾기 버튼 (블루투스 켜져있고 연결 안됐을 때만)
                if (isBluetoothOn && connectedDevice == null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSearching
                          ? null
                          : searchDevices, // 검색 중이면 비활성화
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(16),
                      ),
                      child: Text(isSearching ? '찾는 중...' : '장치 찾기'),
                    ),
                  ),

                // 연결 끊기 버튼 (연결됐을 때만 표시)
                if (connectedDevice != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: disconnect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(16),
                      ),
                      child: Text('연결 끊기'),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 16),

            // === 메시지 표시 영역 ===
            Expanded(
              // 남은 공간 모두 사용
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // 제목 바
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '받은 메시지',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: clearMessages,
                            child: Text('지우기'),
                          ),
                        ],
                      ),
                    ),

                    // 메시지 리스트
                    Expanded(
                      child: messages.isEmpty
                          ? Center(
                              child: Text(
                                'Arduino에서 보낸 메시지가 여기에 나타납니다',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(8),
                              reverse: true, // 최신 메시지가 아래로
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                int realIndex = messages.length - 1 - index;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 4),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    // Arduino 메시지는 파란색, 시스템 메시지는 회색
                                    color: messages[realIndex].startsWith('받음:')
                                        ? Colors.blue[50]
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    messages[realIndex],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
