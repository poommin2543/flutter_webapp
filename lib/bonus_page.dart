import 'package:flutter/material.dart';
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่ถูกต้อง

class BonusPage extends StatefulWidget {
  final String username;

  BonusPage({required this.username});

  @override
  _BonusPageState createState() => _BonusPageState();
}

class _BonusPageState extends State<BonusPage> {
  double _characterX = 0.0;
  double _characterY = 0.8;
  Duration _duration = Duration(milliseconds: 2000);

  void moveToGate(double x) {
    setState(() {
      _characterX = x;
      _characterY = -0.6;
    });

    // เฉพาะประตูที่ 1 เท่านั้นที่ไปหน้าใหม่
    if (x == -0.6) {
      Future.delayed(_duration, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GateResultPage(
              username: widget.username, // ส่งค่า username จาก BonusPage
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('เลือกประตูของคุณ')),
      body: Stack(
        children: [
          // วาดเส้นทาง
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: PathPainter(),
          ),

          // ตัวละคร
          AnimatedAlign(
            alignment: Alignment(_characterX, _characterY),
            duration: _duration,
            child: Image.asset('assets/images/buddy_8.png', width: 100),
          ),

          // ประตู + ปุ่ม
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => moveToGate(-0.6),
                        child: Text('เส้นทางที่ 1'),
                      ),
                      SizedBox(height: 10),
                      Image.asset('assets/images/Gate.webp', height: 160),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: null, // ปิดการกดปุ่ม
                        child: Text('เส้นทางที่ 2'),
                      ),
                      SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/Gate.webp', height: 160),
                          Icon(
                            Icons.close,
                            size: 60,
                            color: Colors.red.withOpacity(0.7),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 253, 2, 2),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: null, // ปิดการกดปุ่ม
                        child: Text('เส้นทางที่ 3'),
                      ),
                      SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/Gate.webp', height: 160),
                          Icon(
                            Icons.close,
                            size: 60,
                            color: Colors.red.withOpacity(0.7),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 253, 2, 2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// วาดเส้นทางไปแต่ละประตู
class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.5)
      ..strokeWidth = 30
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.8),
      Offset(size.width * 0.25, size.height * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.8),
      Offset(size.width * 0.75, size.height * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
