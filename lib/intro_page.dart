import 'package:flutter/material.dart';
// import 'main.dart'; // สำหรับการกลับไปหน้า LoginPage
import 'chapter1.dart'; // สำหรับการไปหน้า Chapter1

class IntroPage extends StatelessWidget {
  final String username;

  IntroPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Introduction'),
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
                height: 500,
              ),
              SizedBox(height: 20),
              Text(
                'ยินดีต้อนรับเข้าสู่เกม!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'คุณจะได้พบกับบทเรียนและสถานการณ์\nที่จะช่วยให้คุณเข้าใจผลของการสูบบุหรี่ไฟฟ้า',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chapter1Page(
                      chapter: 1, // กำหนดหมายเลขบทที่ต้องการ (ในที่นี้คือ Chapter 1)
                      username: username,
                      onFinished: () {
                        // ตัวอย่างเมื่อเสร็จสิ้นการทำ Chapter1 แล้ว
                      },
                    ),
                  ),
                );
                },
                child: Text('เริ่มบทที่ 1', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 20),
              //ElevatedButton(
              //  style: ElevatedButton.styleFrom(
              //    backgroundColor: Colors.redAccent,
              //  ),
              //  onPressed: () {
              //    Navigator.pushReplacement(
              //      context,
              //      MaterialPageRoute(builder: (context) => LoginPage()),
              //    );
              //  },
              //  child: Text('ออกจากระบบ'),
              //),
            ],
          ),
        ),
      ),
    );
  }
}
