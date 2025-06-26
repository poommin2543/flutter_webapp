// lib/route_selection_page.dart (เดิมคือ bonus_page.dart)
import 'package:flutter/material.dart';
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่รวม
import 'constants.dart'; // นำเข้า AppConstants
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'intro_page.dart'; // ไม่จำเป็นต้องใช้ intro_page โดยตรงในนี้แล้ว

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
    {'id': 1, 'name': 'เส้นทางที่ 1', 'isUnlocked': true, 'gateX': -0.6, 'chapterDescription': 'บททดสอบเกี่ยวกับข้อมูลเบื้องต้น'},
    {'id': 2, 'name': 'เส้นทางที่ 2', 'isUnlocked': true, 'gateX': 0.0, 'chapterDescription': 'บททดสอบเกี่ยวกับความเข้าใจเกี่ยวกับบุหรี่ไฟฟ้า'},
    {'id': 3, 'name': 'เส้นทางที่ 3', 'isUnlocked': true, 'gateX': 0.6, 'chapterDescription': 'บททดสอบเกี่ยวกับการความสามารถในการสื่อสารและประเมินข้อมูล'},
  ];

  @override
  void initState() {
    super.initState();
    // Logic การปลดล็อคถูกจัดการที่ WelcomePage แล้ว
    // หาก currentChapter เป็น 6 หมายถึงจบบทเรียนปัจจุบัน ผู้ใช้สามารถเลือกเส้นทางใหม่ได้
    // ถ้าเป็น 1,1 ก็หมายถึงเริ่มใหม่
  }

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
          message: 'คุณเลือก${routes.firstWhere((r) => r['id'] == selectedRouteId)['name']}ได้แล้ว 🎉',
          chapterDescription: routes.firstWhere((r) => r['id'] == selectedRouteId)['chapterDescription'], // คำอธิบายสำหรับบทแรกของเส้นทาง
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
            child: Image.asset('assets/images/buddy_8.png', width: 100),
          ),

          // ประตู + ปุ่ม
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: routes.map((route) {
                  // ตอนนี้ทุกเส้นทางจะปลดล็อคเสมอในหน้านี้
                  // เพราะหน้านี้ถูกเรียกเมื่อผู้ใช้ "สามารถ" เลือกเส้นทางได้
                  bool isLocked = !route['isUnlocked'];

                  String buttonText = 'เริ่ม: ${route['name']}';

                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: isLocked
                            ? null
                            : () => moveToGate(route['id'], route['gateX']),
                        child: Text(buttonText, textAlign: TextAlign.center,),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // สีเริ่มต้น
                          minimumSize: const Size(150, 40), // กำหนดขนาดขั้นต่ำ
                        ),
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/Gate.webp', height: 160),
                          if (isLocked) // ถ้า isLocked เป็น false ก็จะไม่แสดง icon lock (ตอนนี้จะไม่แสดงแล้ว)
                            Icon(
                              Icons.lock,
                              size: 60,
                              color: Colors.red.withOpacity(0.7),
                            ),
                        ],
                      ),
                      if (isLocked) // จะไม่แสดงแล้ว
                        const SizedBox(height: 5),
                      if (isLocked) // จะไม่แสดงแล้ว
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
