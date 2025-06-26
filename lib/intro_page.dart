// lib/intro_page.dart
import 'package:flutter/material.dart';
// import 'main.dart'; // สำหรับการกลับไปหน้า LoginPage
// import 'chapter1.dart'; // สำหรับการไปหน้า Chapter1
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่ถูกต้อง
// นำเข้า Chapter Pages ของทุกเส้นทาง
import 'chapter1.dart';
import 'chapter2.dart';
import 'chapter3.dart';
import 'chapter4.dart';
import 'chapter5.dart';
import 'chapter1_route2.dart';
import 'chapter2_route2.dart';
import 'chapter3_route2.dart';
import 'chapter4_route2.dart';
import 'chapter5_route2.dart';
import 'chapter1_route3.dart';
import 'chapter2_route3.dart';
import 'chapter3_route3.dart';
import 'chapter4_route3.dart';
import 'chapter5_route3.dart';


class IntroPage extends StatelessWidget {
  final String username;
  final int currentRouteId; // รับ routeId ปัจจุบัน
  final String selectedCharacterName; // รับชื่อตัวละครที่เลือก (ถ้ามี)
  final int targetChapter; // บทที่ต้องการให้ IntroPage นำทางไป (เช่น 1, 2, 3, 4, 5)

  IntroPage({
    required this.username,
    required this.currentRouteId,
    required this.selectedCharacterName, // อาจจะใช้หรือไม่ใช้ก็ได้
    required this.targetChapter,
  });

  // ฟังก์ชันสำหรับเลือก Widget ของ Chapter Page ที่ถูกต้องตาม Route ID และ Chapter Number
  Widget _getChapterPageWidget() {
    switch (currentRouteId) {
      case 1:
        switch (targetChapter) {
          case 1:
            return Chapter1Page(
              chapter: 1,
              username: username,
              onFinished: () {},
              routeId: currentRouteId, // ส่ง routeId
            );
          case 2:
            return Chapter2Page(
              chapter: 2,
              username: username,
              onFinished: () {},
              routeId: currentRouteId, // ส่ง routeId
            );
          case 3:
            return Chapter3Page(
              chapter: 3,
              username: username,
              onFinished: () {},
              routeId: currentRouteId, // ส่ง routeId
            );
          case 4:
            return Chapter4Page(
              chapter: 4,
              username: username,
              onFinished: () {},
              routeId: currentRouteId, // ส่ง routeId
            );
          case 5:
            return Chapter5Page(
              chapter: 5,
              username: username,
              onFinished: () {},
              routeId: currentRouteId, // ส่ง routeId
            );
          default:
            return Text('บทที่ $targetChapter สำหรับเส้นทางที่ $currentRouteId ไม่พร้อมใช้งาน');
        }
      case 2:
        switch (targetChapter) {
          case 1:
            return Chapter1Route2Page(
              chapter: 1,
              username: username,
              onFinished: () {},
              routeId: currentRouteId,
            );
          case 2:
            return Chapter2Route2Page(
              chapter: 2,
              username: username,
              onFinished: () {},
              routeId: currentRouteId,
            );
          case 3:
            return Chapter3Route2Page(
              chapter: 3,
              username: username,
              onFinished: () {},
              routeId: currentRouteId,
            );
          case 4:
            return Chapter4Route2Page(
              chapter: 4,
              username: username,
              onFinished: () {},
              routeId: currentRouteId,
            );
          case 5:
            return Chapter5Route2Page(
              chapter: 5,
              username: username,
              onFinished: () {},
              routeId: currentRouteId,
            );
          default:
            return Text('บทที่ $targetChapter สำหรับเส้นทางที่ $currentRouteId ไม่พร้อมใช้งาน');
        }
      case 3:
        switch (targetChapter) {
          case 1:
            return Chapter1Route3Page(
              chapter: 1,
              username: username,
              onFinished: () {},
              routeId: currentRouteId,
            );
          case 2:
            return Chapter2Route3Page(
              chapter: 2,
              username: username,
              onFinished: () {},
              routeId: currentRouteId,
            );
          case 3:
            return Chapter3Route3Page(
              chapter: 3,
              username: username,
              onFinished: () {},
              routeId: currentRouteId,
            );
          case 4:
            return Chapter4Route3Page(
              chapter: 4,
              username: username,
              onFinished: () {},
              routeId: currentRouteId,
            );
          case 5:
            return Chapter5Route3Page(
              chapter: 5,
              username: username,
              onFinished: () {},
              routeId: currentRouteId,
            );
          default:
            return Text('บทที่ $targetChapter สำหรับเส้นทางที่ $currentRouteId ไม่พร้อมใช้งาน');
        }
      default:
        return Text('เส้นทางที่ $currentRouteId ไม่ถูกต้อง');
    }
  }

  // คำอธิบาย Intro Page ตามบทและเส้นทาง
  String _getIntroDescription() {
    if (targetChapter == 1) {
      return 'ยินดีต้อนรับเข้าสู่เกม!\nคุณจะได้พบกับบทเรียนและสถานการณ์\nที่จะช่วยให้คุณเข้าใจผลของการสูบบุหรี่ไฟฟ้า';
    } else {
      return 'เตรียมพร้อมสำหรับบทที่ $targetChapter ในเส้นทางที่ $currentRouteId!\nมาเรียนรู้และไขปริศนาไปด้วยกัน';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Introduction บทที่ $targetChapter'),
        automaticallyImplyLeading: false, // ❌ ซ่อนปุ่ม back
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Introduction1.webp', // ใส่ภาพแนะนำเกม
                height: 600,
              ),
              const SizedBox(height: 20),
              Text(
                'ยินดีต้อนรับเข้าสู่เกม!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _getIntroDescription(),
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  // นำทางไปยัง Chapter Page ที่ถูกต้อง
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _getChapterPageWidget(),
                    ),
                  );
                },
                child: Text('เริ่มบทที่ $targetChapter'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
