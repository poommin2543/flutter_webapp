import 'package:flutter/material.dart';
import 'chapter1.dart'; // อย่าลืม import

class GateResultPage extends StatefulWidget {
  final String username; // รับค่า username จาก constructor

  GateResultPage({required this.username}); // Constructor รับค่า username

  @override
  _GateResultPageState createState() => _GateResultPageState();
}

class _GateResultPageState extends State<GateResultPage> {
  @override
  void initState() {
    super.initState();
    // หลังจาก 5 วินาทีจะไปที่หน้า Chapter1Page
    Future.delayed(Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Chapter1Page(
            chapter: 1,
            username: widget.username, // ส่ง username ไปยัง Chapter1Page
            onFinished: () {},
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("คุณมาถึงแล้ว!"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'คุณเลือกประตูที่ 1 ได้แล้ว 🎉',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('กำลังเข้าสู่บทที่ 1 ...'),
            SizedBox(height: 10),
            Text(
              'บททดสอบเกี่ยวกับการเข้าถึงข้อมูลที่สำคัญเกี่ยวกับบุหรี่ไฟฟ้า',
            ),
          ],
        ),
      ),
    );
  }
}
