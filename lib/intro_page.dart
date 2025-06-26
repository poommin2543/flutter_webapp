// lib/intro_page.dart
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

class IntroPage extends StatelessWidget {
  final String username;
  final int currentRouteId;
  final String selectedCharacterName;
  final int? targetChapter;

  IntroPage({
    required this.username,
    required this.currentRouteId,
    required this.selectedCharacterName,
    this.targetChapter,
  });

  @override
  Widget build(BuildContext context) {
    String introText = 'ยินดีต้อนรับเข้าสู่เกม!\nคุณจะได้พบกับบทเรียนและสถานการณ์\nที่จะช่วยให้คุณเข้าใจผลของการสูบบุหรี่ไฟฟ้า';
    String buttonText = 'เริ่มบทที่ 1';
    Widget nextPageWidget;

    // กำหนด nextPageWidget ตาม RouteId และ Chapter ที่ต้องการ
    // Default to Chapter 1, Route 1
    nextPageWidget = Chapter1Page(
      chapter: 1,
      username: username,
      routeId: 1, // Default for Route 1
      onFinished: () {},
    );

    if (targetChapter != null) {
      introText = 'เตรียมพร้อมสำหรับบทเรียนบทที่ $targetChapter!\nบทเรียนนี้จะช่วยให้คุณ: \n\n'
                  '${_getChapterIntroDescription(targetChapter!)}';
      buttonText = 'เริ่มบทที่ $targetChapter';

      switch (currentRouteId) {
        case 1: // Route 1
          switch (targetChapter) {
            case 1:
              nextPageWidget = Chapter1Page(chapter: 1, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 2:
              nextPageWidget = Chapter2Page(chapter: 2, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 3:
              nextPageWidget = Chapter3Page(chapter: 3, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 4:
              nextPageWidget = Chapter4Page(chapter: 4, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 5:
              nextPageWidget = Chapter5Page(chapter: 5, username: username, routeId: currentRouteId, onFinished: () {});
              break;
          }
          break;
        case 2: // Route 2
          switch (targetChapter) {
            case 1:
              nextPageWidget = Chapter1Route2Page(chapter: 1, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 2:
              nextPageWidget = Chapter2Route2Page(chapter: 2, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 3:
              nextPageWidget = Chapter3Route2Page(chapter: 3, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 4:
              nextPageWidget = Chapter4Route2Page(chapter: 4, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 5:
              nextPageWidget = Chapter5Route2Page(chapter: 5, username: username, routeId: currentRouteId, onFinished: () {});
              break;
          }
          break;
        case 3: // Route 3
          switch (targetChapter) {
            case 1:
              nextPageWidget = Chapter1Route3Page(chapter: 1, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 2:
              nextPageWidget = Chapter2Route3Page(chapter: 2, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 3:
              nextPageWidget = Chapter3Route3Page(chapter: 3, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 4:
              nextPageWidget = Chapter4Route3Page(chapter: 4, username: username, routeId: currentRouteId, onFinished: () {});
              break;
            case 5:
              nextPageWidget = Chapter5Route3Page(chapter: 5, username: username, routeId: currentRouteId, onFinished: () {});
              break;
          }
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(targetChapter == null ? 'บทนำ' : 'บทนำบทที่ $targetChapter'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Introduction1.webp',
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => nextPageWidget,
                    ),
                  );
                },
                child: Text(buttonText, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('กลับหน้าเลือกเส้นทาง'),
                onPressed: () {
                  Navigator.pop(context);
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
