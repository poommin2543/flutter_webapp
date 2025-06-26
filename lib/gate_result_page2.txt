import 'package:flutter/material.dart';
//import 'intro2_page.dart'; // อย่าลืม import
import 'chapter3.dart'; // อย่าลืม import

class GateResultPage extends StatefulWidget {
  final String username; // รับค่า username จาก constructor
  final int chapter;
  GateResultPage({
    required this.username,
    required this.chapter,
  }); // Constructor รับค่า username

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
          builder: (context) => Chapter3Page(
            chapter: 3,
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
      appBar: AppBar(title: Text("จบบทที่ 2 แล้ว")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'เจอข้อมูลตึงๆ แต่ก็คือสาระที่ควรรู้ มาลองดูกันต่อนะ 🎉',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('กำลังเข้าสู่บทที่ 3 ...'),
            SizedBox(height: 10),
            Text('บททดสอบเกี่ยวกับความสามารถในการสื่อสารและประเมินข้อมูล'),
          ],
        ),
      ),
    );
  }
}
