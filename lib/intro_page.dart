import 'package:flutter/material.dart';
import 'main.dart'; // สำหรับการกลับไปหน้า LoginPage
import 'chapter1.dart'; // สำหรับการไปหน้า Chapter1

class IntroPage extends StatelessWidget {
  final String username;

  IntroPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Introduction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Introduction!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Here you will get an overview of the chapters and topics.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // ไปที่หน้า Chapter1
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => Chapter1Page(username: username)),
                // );
              },
              child: Text('Start Chapter 1'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // กลับไปหน้า LoginPage
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
