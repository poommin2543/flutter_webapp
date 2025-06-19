import 'package:flutter/material.dart';
import 'main.dart'; // สำหรับการกลับไปหน้า LoginPage
import 'intro_page.dart'; // สำหรับการไปหน้า Intro
//1import 'intro_carousel.dart';

class WelcomePage extends StatelessWidget {
  final String fullName;
  final String username;

  WelcomePage({required this.fullName, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
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
              SizedBox(height: 20),
              Text(
                'ยินดีต้อนรับ, $fullName!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text('Username: $username', style: TextStyle(fontSize: 18)),
              SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.arrow_forward),
                label: Text('Start / เริ่ม'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IntroPage(username: username),
                    ),
                  );
                },
              ),

              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
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
