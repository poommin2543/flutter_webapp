// lib/intro_page.dart
import 'package:flutter/material.dart';
import 'chapter1.dart'; // สำหรับการไปหน้า Chapter1

class IntroPage extends StatelessWidget {
  final String username;
  final int currentRouteId; // เพิ่ม: เพื่อส่งผ่านค่า route_id ที่เลือกแล้ว
  final String selectedCharacterName; // เพิ่ม: เพื่อส่งชื่อตัวละครที่เลือก

  IntroPage({
    required this.username,
    required this.currentRouteId, // ต้องรับค่านี้มา
    required this.selectedCharacterName, // ต้องรับค่านี้มา
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บทนำ'),
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
              const Text(
                'ยินดีต้อนรับเข้าสู่เกม!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'คุณจะได้พบกับบทเรียนและสถานการณ์\nที่จะช่วยให้คุณเข้าใจผลของการสูบบุหรี่ไฟฟ้า',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chapter1Page(
                        chapter: 1, // กำหนดหมายเลขบทที่ต้องการ (ในที่นี้คือ Chapter 1)
                        username: username,
                        routeId: currentRouteId, // ส่ง routeId ที่เลือกแล้ว
                        onFinished: () {
                          // ตัวอย่างเมื่อเสร็จสิ้นการทำ Chapter1 แล้ว
                          // อาจจะ fetch score หรือทำอะไรบางอย่าง
                        },
                      ),
                    ),
                  );
                },
                child: const Text('เริ่มบทที่ 1', style: TextStyle(fontSize: 18)),
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
}
