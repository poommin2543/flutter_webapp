// lib/route_selection_page.dart (เดิมคือ bonus_page.dart)
import 'package:flutter/material.dart';
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่รวม
import 'constants.dart'; // นำเข้า AppConstants
// import 'package:http/http.dart' as http; // ไม่จำเป็นต้องใช้ในหน้านี้โดยตรง
// import 'dart:convert'; // ไม่จำเป็นต้องใช้ในหน้านี้โดยตรง

class RouteSelectionPage extends StatefulWidget {
  final String username;
  final String fullName;
  final int currentChapter; // รับ currentChapter (จาก WelcomePage)
  final int currentRouteID; // รับ currentRouteID (จาก WelcomePage)
  final String selectedCharacterName; // รับชื่อตัวละครที่เลือก

  RouteSelectionPage({
    required this.username,
    required this.fullName,
    required this.currentChapter,
    required this.currentRouteID,
    required this.selectedCharacterName,
  });

  @override
  _RouteSelectionPageState createState() => _RouteSelectionPageState();
}

class _RouteSelectionPageState extends State<RouteSelectionPage> {
  // ตัวละครปัจจุบัน (จะขยับเมื่อเลือกประตู)
  double _characterX = 0.0;
  double _characterY = 0.8;
  Duration _duration = const Duration(milliseconds: 2000);

  // กำหนดเส้นทาง
  final List<Map<String, dynamic>> routes = [
    {
      'id': 1,
      'name': 'เส้นทางที่ 1',
      'isUnlocked': false,
      'gateX': -0.6,
      'chapterDescription': 'บททดสอบเกี่ยวกับข้อมูลเบื้องต้น',
    },
    {
      'id': 2,
      'name': 'เส้นทางที่ 2',
      'isUnlocked': true,
      'gateX': 0.0,
      'chapterDescription': 'บททดสอบเกี่ยวกับความเข้าใจเกี่ยวกับบุหรี่ไฟฟ้า',
    },
    {
      'id': 3,
      'name': 'เส้นทางที่ 3',
      'isUnlocked': false,
      'gateX': 0.6,
      'chapterDescription':
          'บททดสอบเกี่ยวกับการความสามารถในการสื่อสารและประเมินข้อมูล',
    },
    //{
    //  'id': 4,
    //  'name': 'เส้นทางลับ',
    //  'isUnlocked': false,
    //  'gateX': 0.8,
    //  'gateY': -0.6,
    //  'chapterDescription': 'การผจญภัยเพื่อต่อต้านภัยจากบุหรี่ไฟฟ้า',
    //},
    //{
    //  'id': 5,
    //  'name': 'เส้นทางลับ',
    //  'isUnlocked': false,
    //  'gateX': 0.8,
    //  'gateY': -0.6,
    //  'chapterDescription': 'การผจญภัยเพื่อต่อต้านภัยจากบุหรี่ไฟฟ้า',
    //},
  ];

  // ฟังก์ชันสำหรับเคลื่อนย้ายตัวละครไปยังประตูและนำทาง
  void moveToGate(int selectedRouteId, double gateX) async {
    setState(() {
      _characterX = gateX;
      _characterY = -0.6; // ตัวละครจะเคลื่อนที่ไปด้านบน
    });

    await Future.delayed(_duration); // รอให้ Animation จบ

    if (!mounted) return;

    // เมื่อเลือกเส้นทางใหม่ จะเริ่มต้นบทที่ 1 เสมอ
    int chapterToStart = 1;

    // นำทางไปยัง GateResultPage เพื่ออัปเดต Backend และนำทางต่อ
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GateResultPage(
          username: widget.username,
          nextChapter: chapterToStart, // จะไปบทที่ 1 ของเส้นทางใหม่
          nextRouteId: selectedRouteId, // เส้นทางที่เลือก
          message:
              'คุณเลือก${routes.firstWhere((r) => r['id'] == selectedRouteId)['name']}ได้แล้ว 🎉',
          chapterDescription: routes.firstWhere(
            (r) => r['id'] == selectedRouteId,
          )['chapterDescription'], // คำอธิบายสำหรับบทแรกของเส้นทาง
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกประตูของคุณ'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // วาดเส้นทาง
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: PathPainter(),
          ),

          // ตัวละคร
          AnimatedAlign(
            alignment: Alignment(_characterX, _characterY),
            duration: _duration,
            child: Builder(
              builder: (context) {
                String imagePath;
                if (widget.selectedCharacterName == 'Ben') {
                  imagePath = 'assets/images/buddy_8.png';
                } else if (widget.selectedCharacterName == 'Ava') {
                  imagePath = 'assets/images/buddy_2.png';
                } else if (widget.selectedCharacterName == 'Chloe') {
                  imagePath = 'assets/images/buddy_5.png';
                } else {
                  imagePath = 'assets/images/buddy_8R.png'; // fallback
                }
                return Image.asset(imagePath, width: 100);
              },
            ),
          ),

          // ประตู + ปุ่ม
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: routes.map((route) {
                  bool isLocked = !route['isUnlocked'];
                  String buttonText = 'เริ่ม: ${route['name']}';

                  return Column(
                    children: [
                      // Button stays on top
                      ElevatedButton(
                        onPressed: isLocked
                            ? null
                            : () => moveToGate(route['id'], route['gateX']),
                        child: Text(buttonText, textAlign: TextAlign.center),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(150, 40),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Make the gate image clickable
                      GestureDetector(
                        onTap: isLocked
                            ? null
                            : () => moveToGate(route['id'], route['gateX']),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              route['image'] ?? 'assets/images/MainGate.png',
                              height: 160,
                            ),
                            if (isLocked)
                              Icon(
                                Icons.lock,
                                size: 60,
                                color: Colors.red.withOpacity(0.7),
                              ),
                          ],
                        ),
                      ),
                      if (isLocked) const SizedBox(height: 5),
                      if (isLocked)
                        const Text(
                          'Coming Soon',
                          style: TextStyle(
                            color: Color.fromARGB(255, 253, 2, 2),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          // ปุ่มกลับหน้าหลัก
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('กลับหน้าเลือกตัวละคร'),
                onPressed: () {
                  Navigator.pop(context); // กลับไปหน้าเลือกตัวละคร
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// วาดเส้นทางไปแต่ละประตู (เหมือนเดิม)
class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.5)
      ..strokeWidth = 30
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.8),
      Offset(size.width * 0.25, size.height * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.8),
      Offset(size.width * 0.75, size.height * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
