// lib/gate_result_page.dart (รวมทุก gate_result_page เข้าด้วยกัน)
import 'package:flutter/material.dart';
import 'chapter1.dart'; // Route 1, Chapter 1
import 'chapter2.dart'; // Route 1, Chapter 2
import 'chapter3.dart'; // Route 1, Chapter 3
import 'chapter4.dart'; // Route 1, Chapter 4
import 'chapter5.dart'; // Route 1, Chapter 5

// Chapters for Route 2
import 'chapter1_route2.dart';
import 'chapter2_route2.dart';
import 'chapter3_route2.dart';
import 'chapter4_route2.dart';
import 'chapter5_route2.dart';

// Chapters for Route 3
import 'chapter1_route3.dart';
import 'chapter2_route3.dart';
import 'chapter3_route3.dart';
import 'chapter4_route3.dart';
import 'chapter5_route3.dart';

import 'intro_page.dart'; // ใช้ IntroPage เป็นทางเข้าบทอื่นๆ
import 'summary_page.dart'; // สำหรับตอนจบบทที่ 5
import 'constants.dart'; // นำเข้า AppConstants
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'welcome_page.dart'; // เพิ่ม: สำหรับกลับไปหน้า Welcome หลังจากจบบทที่ 5

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
    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted) return; // ตรวจสอบว่า widget ยังอยู่บน tree ก่อนนำทาง

      Widget targetPage;

      // Logic การนำทางไปยังบทต่อไป หรือหน้าสรุป หรือ WelcomePage
      if (widget.nextChapter == 6) { // ถ้าเป็นบทที่ 6 (หมายถึงจบบทที่ 5 แล้ว)
         targetPage = SummaryPage(username: widget.username);
         // หลังจาก SummaryPage จบ ผู้ใช้จะกลับไปที่ WelcomePage และเห็นปุ่ม "เลือกเส้นทางใหม่"
      } else {
        // นำทางไปยัง IntroPage ก่อนเข้า Chapter จริง
        targetPage = IntroPage(
          username: widget.username,
          currentRouteId: widget.nextRouteId,
          selectedCharacterName: 'ตัวละคร', // หรือชื่อตัวละครที่แท้จริง
          targetChapter: widget.nextChapter,
        );
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
            // หาก nextChapter เป็น 6 ให้แสดงข้อความที่แตกต่าง
            Text(
              widget.nextChapter == 6
                  ? 'กำลังเข้าสู่หน้าสรุปบทเรียน...'
                  : 'กำลังเข้าสู่บทที่ ${widget.nextChapter} ...',
            ),
            const SizedBox(height: 10),
            Text(widget.chapterDescription),
          ],
        ),
      ),
    );
  }
}
