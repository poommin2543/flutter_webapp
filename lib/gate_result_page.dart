// lib/gate_result_page.dart (รวมทุก gate_result_page เข้าด้วยกัน)
import 'package:flutter/material.dart';
// import 'chapter1.dart';
// import 'chapter2.dart';
// import 'chapter3.dart';
// import 'chapter4.dart';
// import 'chapter5.dart';
import 'intro_page.dart'; // ใช้ IntroPage เป็นทางเข้าบทอื่นๆ
import 'summary_page.dart'; // สำหรับตอนจบบทที่ 5
import 'constants.dart'; // นำเข้า AppConstants
import 'package:http/http.dart' as http;
import 'dart:convert';

class GateResultPage extends StatefulWidget {
  final String username;
  final int nextChapter; // บทต่อไปที่จะไป
  final int nextRouteId; // เส้นทางปัจจุบัน/ต่อไป (จากที่เลือกมา)
  final String message; // ข้อความแสดงผล
  final String chapterDescription; // คำอธิบายบทต่อไป

  GateResultPage({
    required this.username,
    required this.nextChapter,
    required this.nextRouteId,
    required this.message,
    required this.chapterDescription,
  });

  @override
  _GateResultPageState createState() => _GateResultPageState();
}

class _GateResultPageState extends State<GateResultPage> {
  @override
  void initState() {
    super.initState();
    // อัปเดตความคืบหน้าใน Backend ก่อนนำทาง
    _updateProgressAndNavigate();
  }

  Future<void> _updateProgressAndNavigate() async {
    // อัปเดต current_chapter และ current_route_id ใน Backend
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/update_progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'current_chapter': widget.nextChapter,
          'current_route_id': widget.nextRouteId,
        }),
      );

      if (response.statusCode == 200) {
        print('Progress updated successfully!');
      } else {
        print('Failed to update progress: ${response.body}');
      }
    } catch (e) {
      print('Error updating progress: $e');
    }

    // หลังจากอัปเดต Backend แล้วค่อยนำทาง
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return; // ตรวจสอบว่า widget ยังอยู่บน tree ก่อนนำทาง

      Widget targetPage;

      // Logic การนำทางไปยังบทต่อไป หรือหน้าสรุป
      if (widget.nextChapter == 6) { // ถ้าเป็นบทที่ 6 (หมายถึงจบบทที่ 5 แล้ว) ให้ไปหน้า SummaryPage
         targetPage = SummaryPage(username: widget.username);
      } else if (widget.nextChapter == 1) { // ถ้าเป็น Chapter 1 ให้ไปที่ IntroPage (ของบท 1)
        targetPage = IntroPage(
          username: widget.username,
          currentRouteId: widget.nextRouteId,
          selectedCharacterName: 'ตัวละคร', // ใส่ค่าชั่วคราว หรือรับมาจาก WelcomePage
          targetChapter: 1,
        );
      } else if (widget.nextChapter == 2) { // ถ้าจะไปบทที่ 2 ให้ไป IntroPage (ของบท 2)
        targetPage = IntroPage(
          username: widget.username,
          currentRouteId: widget.nextRouteId,
          selectedCharacterName: 'ตัวละคร', // ใส่ค่าชั่วคราว หรือรับมาจาก WelcomePage
          targetChapter: 2, // ระบุว่าเป็น Intro สำหรับบทที่ 2
        );
      } else if (widget.nextChapter == 3) { // ถ้าจะไปบทที่ 3 ให้ไป IntroPage (ของบท 3)
        targetPage = IntroPage(
          username: widget.username,
          currentRouteId: widget.nextRouteId,
          selectedCharacterName: 'ตัวละคร',
          targetChapter: 3,
        );
      } else if (widget.nextChapter == 4) { // ถ้าจะไปบทที่ 4 ให้ไป IntroPage (ของบท 4)
        targetPage = IntroPage(
          username: widget.username,
          currentRouteId: widget.nextRouteId,
          selectedCharacterName: 'ตัวละคร',
          targetChapter: 4,
        );
      } else if (widget.nextChapter == 5) { // ถ้าจะไปบทที่ 5 ให้ไป IntroPage (ของบท 5)
        targetPage = IntroPage(
          username: widget.username,
          currentRouteId: widget.nextRouteId,
          selectedCharacterName: 'ตัวละคร',
          targetChapter: 5,
        );
      }
      else {
        // Fallback: กรณีที่ไม่ตรงกับเงื่อนไขใดๆ อาจจะกลับหน้าหลักหรือหน้าสรุป
        targetPage = SummaryPage(username: widget.username); // Fallback ไปหน้า Summary
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetPage),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.message.contains('แล้ว!') ? "คุณมาถึงแล้ว!" : "จบบทที่ ${widget.nextChapter - 1} แล้ว"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.message,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Text('กำลังเข้าสู่บทที่ ${widget.nextChapter} ...'),
            const SizedBox(height: 10),
            Text(widget.chapterDescription),
          ],
        ),
      ),
    );
  }
}
