import 'package:flutter/material.dart';
import 'main.dart'; // สำหรับการกลับไปหน้า LoginPage
import 'intro_page.dart'; // สำหรับการไปหน้า Intro

class WelcomePage extends StatelessWidget {
  final String fullName;
  final String username;

  WelcomePage({
    required this.fullName,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome, $fullName!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Username: $username',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // ไปที่หน้า Intro
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IntroPage(username: username)),
                );
              },
              child: Text('Go to Intro'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // การกลับไปหน้า LoginPage (ออกจากระบบ)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
