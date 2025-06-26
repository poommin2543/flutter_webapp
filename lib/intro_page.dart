// lib/intro_page.dart
import 'package:flutter/material.dart';
import 'chapter1.dart'; // สำหรับการไปหน้า Chapter1
import 'chapter2.dart'; // สำหรับการไปหน้า Chapter2
import 'chapter3.dart'; // สำหรับการไปหน้า Chapter3
import 'chapter4.dart'; // สำหรับการไปหน้า Chapter4
import 'chapter5.dart'; // สำหรับการไปหน้า Chapter5
// import 'intro2_page.dart'; // ไม่จำเป็นต้อง import ถ้าไม่ใช้ IntroPage แยกสำหรับบทที่ 2

class IntroPage extends StatelessWidget {
  final String username;
  final int currentRouteId; // เพิ่ม: เพื่อส่งผ่านค่า route_id ที่เลือกแล้ว
  final String selectedCharacterName; // เพิ่ม: เพื่อส่งชื่อตัวละครที่เลือก
  final int? targetChapter; // **แก้ไขตรงนี้: เพิ่มพารามิเตอร์ targetChapter เป็น optional**

  IntroPage({
    required this.username,
    required this.currentRouteId, // ต้องรับค่านี้มา
    required this.selectedCharacterName, // ต้องรับค่านี้มา
    this.targetChapter, // **แก้ไขตรงนี้: กำหนดให้เป็น optional named parameter**
  });

  @override
  Widget build(BuildContext context) {
    String introText = 'ยินดีต้อนรับเข้าสู่เกม!\nคุณจะได้พบกับบทเรียนและสถานการณ์\nที่จะช่วยให้คุณเข้าใจผลของการสูบบุหรี่ไฟฟ้า';
    String buttonText = 'เริ่มบทที่ 1';
    Widget nextPageWidget = Chapter1Page( // Default to Chapter 1
      chapter: 1,
      username: username,
      routeId: currentRouteId,
      onFinished: () {},
    );

    if (targetChapter != null) {
      introText = 'เตรียมพร้อมสำหรับบทเรียนบทที่ $targetChapter!\nบทเรียนนี้จะช่วยให้คุณ: \n\n'
                  '${_getChapterIntroDescription(targetChapter!)}';
      buttonText = 'เริ่มบทที่ $targetChapter';

      switch (targetChapter) {
        case 1:
          nextPageWidget = Chapter1Page(
            chapter: 1,
            username: username,
            routeId: currentRouteId,
            onFinished: () {},
          );
          break;
        case 2:
          nextPageWidget = Chapter2Page( // บทที่ 2 ไม่มี Intro แยก ให้ไป Chapter2 โดยตรง
            username: username,
            chapter: 2,
            routeId: currentRouteId,
            onFinished: (){},
          );
          break;
        case 3:
          nextPageWidget = Chapter3Page(
            username: username,
            chapter: 3,
            routeId: currentRouteId,
            onFinished: (){},
          );
          break;
        case 4:
          nextPageWidget = Chapter4Page(
            username: username,
            chapter: 4,
            routeId: currentRouteId,
            onFinished: (){},
          );
          break;
        case 5:
          nextPageWidget = Chapter5Page(
            username: username,
            chapter: 5,
            routeId: currentRouteId,
            onFinished: (){},
          );
          break;
        default:
          nextPageWidget = Chapter1Page( // Fallback
            chapter: 1,
            username: username,
            routeId: currentRouteId,
            onFinished: () {},
          );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(targetChapter == null ? 'บทนำ' : 'บทนำบทที่ $targetChapter'),
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
                introText,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  Navigator.pushReplacement( // ใช้ pushReplacement เพื่อไม่ให้ย้อนกลับมาที่ Intro Page เดิม
                    context,
                    MaterialPageRoute(
                      builder: (context) => nextPageWidget,
                    ),
                  );
                },
                child: Text(buttonText, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              // ปุ่มกลับหน้าเลือกเส้นทาง
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('กลับหน้าเลือกเส้นทาง'),
                onPressed: () {
                  Navigator.pop(context); // กลับไปยัง RouteSelectionPage
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันช่วยสำหรับข้อความแนะนำแต่ละบท
  String _getChapterIntroDescription(int chapter) {
    switch (chapter) {
      case 1:
        return 'ทำความเข้าใจข้อมูลเบื้องต้นเกี่ยวกับบุหรี่ไฟฟ้า';
      case 2:
        return 'ประเมินความรู้ความเข้าใจเกี่ยวกับบุหรี่ไฟฟ้าผ่านวิดีโอและคำถาม';
      case 3:
        return 'ฝึกฝนความสามารถในการสื่อสารและประเมินข้อมูลที่ได้รับ';
      case 4:
        return 'เรียนรู้การตัดสินใจที่ถูกต้องเมื่อถูกชักชวนให้สูบบุหรี่ไฟฟ้า';
      case 5:
        return 'เรียนรู้การจัดการตนเองและสรุปบทเรียนสำคัญจากประสบการณ์ที่ผ่านมา';
      default:
        return 'เตรียมพร้อมสำหรับบทเรียนต่อไป!';
    }
  }
}
