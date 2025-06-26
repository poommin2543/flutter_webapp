// lib/route_selection_page.dart (เดิมคือ bonus_page.dart)
import 'package:flutter/material.dart';
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่รวม
import 'constants.dart'; // นำเข้า AppConstants
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'intro_page.dart'; // สำหรับ Intro ของบทที่ 1 หรืออื่นๆ

class RouteSelectionPage extends StatefulWidget {
  final String username;
  final String fullName;
  final int currentChapter; // รับค่า currentChapter มาด้วย (จาก Backend)
  final int currentRouteId; // รับค่า currentRouteId มาด้วย (จาก Backend)
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
    {'id': 1, 'name': 'เส้นทางที่ 1', 'isUnlocked': true, 'gateX': -0.6, 'chapterDescription': 'บททดสอบเกี่ยวกับข้อมูลเบื้องต้น'},
    {'id': 2, 'name': 'เส้นทางที่ 2', 'isUnlocked': true, 'gateX': 0.0, 'chapterDescription': 'บททดสอบเกี่ยวกับความเข้าใจเกี่ยวกับบุหรี่ไฟฟ้า'}, // **ปรับเป็น true**
    {'id': 3, 'name': 'เส้นทางที่ 3', 'isUnlocked': true, 'gateX': 0.6, 'chapterDescription': 'บททดสอบเกี่ยวกับการความสามารถในการสื่อสารและประเมินข้อมูล'}, // **ปรับเป็น true**
  ];

  @override
  void initState() {
    super.initState();
    // ตอนนี้ไม่จำเป็นต้องใช้ลูปนี้แล้ว เนื่องจากเรา hardcode isUnlocked เป็น true
    // หากต้องการให้การปลดล็อคยังขึ้นอยู่กับความคืบหน้าของผู้ใช้ใน Backend
    // ให้คงโค้ดนี้ไว้และแก้ไข 'isUnlocked' ใน List 'routes' ให้เป็น false ตั้งต้น
    // for (var route in routes) {
    //   if (route['id'] <= widget.currentRouteId) {
    //     route['isUnlocked'] = true;
    //   }
    // }
  }

  // ฟังก์ชันสำหรับเคลื่อนย้ายตัวละครไปยังประตูและนำทาง
  void moveToGate(int selectedRouteId, double gateX) async {
    setState(() {
      _characterX = gateX;
      _characterY = -0.6; // ตัวละครจะเคลื่อนที่ไปด้านบน
    });

    await Future.delayed(_duration); // รอให้ Animation จบ

    if (!mounted) return;

    // ตรวจสอบว่าผู้ใช้เลือกเส้นทางปัจจุบันที่ทำค้างไว้หรือไม่
    int chapterToStart = 1;
    if (selectedRouteId == widget.currentRouteId) {
      // ถ้าเลือกเส้นทางเดิมที่เคยทำค้างไว้ ให้ไปที่ chapter ที่ค้างไว้
      chapterToStart = widget.currentChapter;
    } else {
      // ถ้าเลือกเส้นทางใหม่ ให้เริ่มต้นที่ chapter 1 ของเส้นทางนั้น
      chapterToStart = 1;
    }

    // อัปเดต current_chapter และ current_route_id ใน backend
    // ไม่ว่าจะเป็นการเล่นต่อ หรือเริ่มเส้นทางใหม่ ก็ต้องอัปเดต state ใน backend
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/update_progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'current_chapter': chapterToStart,
          'current_route_id': selectedRouteId,
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
    // GateResultPage จะตัดสินใจว่าจะไปหน้า IntroPage หรือ ChapterPage ที่เหมาะสม
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GateResultPage(
          username: widget.username,
          nextChapter: chapterToStart, // จะไปบทที่ถูกต้องตามความคืบหน้า
          nextRouteId: selectedRouteId, // ส่ง routeId ที่เลือกไปให้ GateResultPage
          message: 'คุณเลือก${routes.firstWhere((r) => r['id'] == selectedRouteId)['name']}ได้แล้ว 🎉',
          chapterDescription: routes.firstWhere((r) => r['id'] == selectedRouteId)['chapterDescription'], // คำอธิบายสำหรับบทแรกของเส้นทาง
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // การวนลูปนี้อาจไม่จำเป็นแล้ว ถ้า routes ถูกกำหนดให้ isUnlocked: true ตั้งแต่แรก
    // แต่เก็บไว้เพื่อการแสดงผล icon lock เผื่อมีการเปลี่ยนแปลง logic ในอนาคต
    for (var route in routes) {
      // route['isUnlocked'] = route['id'] <= widget.currentRouteId; // Old logic
      // No change needed here if you want all routes unlocked by default in the list above.
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
                  // หากเรา hardcode isUnlocked เป็น true แล้ว isLocked จะเป็น false เสมอ
                  bool isLocked = !route['isUnlocked'];
                  // กำหนดข้อความแสดงว่าเส้นทางนี้คือเส้นทางปัจจุบันที่ทำค้างไว้
                  bool isCurrentRoute = route['id'] == widget.currentRouteId && widget.currentChapter <= 5;
                  String buttonText = route['name'];
                  if (isLocked) {
                    buttonText = 'Locked'; // จะไม่เกิดขึ้นแล้วถ้า isUnlocked เป็น true
                  } else if (isCurrentRoute) {
                    buttonText = 'เล่นต่อ: ${route['name']} (บทที่ ${widget.currentChapter})';
                  } else {
                    buttonText = 'เริ่ม: ${route['name']}';
                  }

                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: isLocked
                            ? null
                            : () => moveToGate(route['id'], route['gateX']),
                        child: Text(buttonText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isLocked ? Colors.grey : (isCurrentRoute ? Colors.orange : Colors.blue),
                          minimumSize: const Size(150, 40), // กำหนดขนาดขั้นต่ำ
                        ),
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/Gate.webp', height: 160),
                          if (isLocked) // ถ้า isLocked เป็น false ก็จะไม่แสดง icon lock
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
