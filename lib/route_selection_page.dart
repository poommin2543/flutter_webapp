// lib/route_selection_page.dart (เดิมคือ bonus_page.dart)
import 'package:flutter/material.dart';
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่รวม
import 'constants.dart'; // นำเข้า AppConstants
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteSelectionPage extends StatefulWidget {
  final String username;
  final String fullName;
  final int currentChapter; // รับค่า currentChapter มาด้วย
  final int currentRouteId; // รับค่า currentRouteId มาด้วย
  final String selectedCharacterName; // รับชื่อตัวละครที่เลือก

  RouteSelectionPage({
    required this.username,
    required this.fullName,
    required this.currentChapter,
    required this.currentRouteId,
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
    {'id': 1, 'name': 'เส้นทางที่ 1', 'isUnlocked': true, 'gateX': -0.6},
    {'id': 2, 'name': 'เส้นทางที่ 2', 'isUnlocked': false, 'gateX': 0.0},
    {'id': 3, 'name': 'เส้นทางที่ 3', 'isUnlocked': false, 'gateX': 0.6},
  ];

  // ฟังก์ชันสำหรับเคลื่อนย้ายตัวละครไปยังประตูและนำทาง
  void moveToGate(int routeId, double gateX) async {
    setState(() {
      _characterX = gateX;
      _characterY = -0.6; // ตัวละครจะเคลื่อนที่ไปด้านบน
    });

    await Future.delayed(_duration); // รอให้ Animation จบ

    // อัปเดต current_route_id ใน backend
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/update_progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'current_chapter': 1, // เริ่มต้นบทที่ 1 ของเส้นทางใหม่
          'current_route_id': routeId, // อัปเดต route_id
        }),
      );

      if (response.statusCode == 200) {
        print('Route progress updated successfully!');
      } else {
        print('Failed to update route progress: ${response.body}');
      }
    } catch (e) {
      print('Error updating route progress: $e');
    }

    // นำทางไปยัง GateResultPage โดยส่งข้อมูล routeId และ chapter ที่จะไปต่อ
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GateResultPage(
          username: widget.username,
          nextChapter: 1, // จะเริ่มบทที่ 1 ของเส้นทางที่เลือก
          nextRouteId: routeId, // ส่ง routeId ที่เลือกไปให้ GateResultPage
          message: 'คุณเลือก${routes.firstWhere((r) => r['id'] == routeId)['name']}ได้แล้ว 🎉',
          chapterDescription: 'บททดสอบเกี่ยวกับข้อมูลเบื้องต้น', // คำอธิบายสำหรับบทแรกของเส้นทาง
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดสถานะการปลดล็อคเส้นทางตาม currentRouteId ของผู้ใช้
    for (var route in routes) {
      if (route['id'] <= widget.currentRouteId) {
        route['isUnlocked'] = true;
      }
    }

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
                  bool isLocked = !route['isUnlocked'];
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: isLocked
                            ? null
                            : () => moveToGate(route['id'], route['gateX']),
                        child: Text(route['name']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isLocked ? Colors.grey : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/Gate.webp', height: 160),
                          if (isLocked)
                            Icon(
                              Icons.lock,
                              size: 60,
                              color: Colors.red.withOpacity(0.7),
                            ),
                        ],
                      ),
                      if (isLocked)
                        const SizedBox(height: 5),
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
