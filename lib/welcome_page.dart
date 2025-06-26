// lib/welcome_page.dart
import 'package:flutter/material.dart';
import 'main.dart'; // สำหรับการกลับไปหน้า LoginPage
import 'character_selection_page.dart'; // นำเข้าหน้าเลือกตัวละคร
import 'user_profile_page.dart'; // นำเข้าหน้าโปรไฟล์ผู้ใช้
import 'leaderboard_page.dart'; // นำเข้าหน้า Leaderboard
import 'comments_page.dart'; // นำเข้าหน้า Comments
import 'survey_page.dart'; // นำเข้าหน้า Survey
import 'gate_result_page.dart'; // เพิ่ม: สำหรับการเล่นต่อ

class WelcomePage extends StatelessWidget {
  final String fullName;
  final String username;
  final int currentChapter; // รับ current_chapter
  final int currentRouteID; // รับ current_route_id

  WelcomePage({
    required this.fullName,
    required this.username,
    required this.currentChapter,
    required this.currentRouteID,
  });

  @override
  Widget build(BuildContext context) {
    // กำหนดปุ่มและ Logic การนำทางหลัก
    Widget mainActionButton;
    String buttonText;
    Function() onPressedAction;

    // ตรวจสอบสถานะความคืบหน้า
    // currentChapter == 1 && currentRouteID == 1: ผู้ใช้ใหม่ หรือเพิ่งรีเซ็ตทั้งหมด หรือจบบทที่ 5 เส้นทางใดเส้นทางหนึ่งแล้ว
    // currentChapter > 1 && currentChapter <= 5: กำลังเล่นค้างอยู่
    // currentChapter == 6: ใช้เป็นสถานะบอกว่าจบบทเรียนในเส้นทางนั้นๆ แล้ว (Backend ตั้งค่าเมื่อจบบท 5)

    if (currentChapter > 1 && currentChapter <= 5) {
      // กำลังเล่นค้างอยู่
      buttonText = 'เล่นต่อ เส้นทางที่ $currentRouteID บทที่ $currentChapter';
      onPressedAction = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GateResultPage(
              username: username,
              nextChapter: currentChapter, // เล่นต่อที่บทนี้
              nextRouteId: currentRouteID, // ในเส้นทางนี้
              message: 'กลับมาที่เส้นทางที่ $currentRouteID บทที่ $currentChapter แล้ว 🎉',
              chapterDescription: 'กำลังเข้าสู่บทเรียนที่คุณทำค้างไว้',
            ),
          ),
        );
      };
    } else {
      // ผู้ใช้ใหม่, เพิ่งรีเซ็ตทั้งหมด หรือจบบทที่ 5 เส้นทางใดเส้นทางหนึ่งแล้ว (currentChapter จะเป็น 6)
      buttonText = 'เริ่มเกมใหม่ / เลือกเส้นทาง';
      onPressedAction = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterSelectionPage(
              username: username,
              fullName: fullName,
              currentChapter: currentChapter, // ส่งค่าปัจจุบันไป
              currentRouteID: currentRouteID, // ส่งค่าปัจจุบันไป
            ),
          ),
        );
      };
    }

    mainActionButton = ElevatedButton.icon(
      icon: const Icon(Icons.play_arrow),
      label: Text(buttonText),
      onPressed: onPressedAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('ยินดีต้อนรับ')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/buddy_8.png', // เปลี่ยนชื่อไฟล์ตามที่คุณมี
                height: 300,
              ),
              const SizedBox(height: 20),
              Text(
                'ยินดีต้อนรับ, $fullName!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text('Username: $username', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 40),
              mainActionButton, // ใช้ปุ่มที่สร้างจาก Logic ด้านบน
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('โปรไฟล์ผู้ใช้'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(username: username),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.leaderboard),
                label: const Text('กระดานผู้นำ'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LeaderboardPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.comment),
                label: const Text('ความคิดเห็น'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CommentsPage(username: username)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.assignment),
                label: const Text('แบบสำรวจ'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SurveyPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('ออกจากระบบ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
