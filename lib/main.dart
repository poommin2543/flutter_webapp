// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'register_page.dart';
import 'welcome_page.dart';
import 'constants.dart'; // นำเข้า AppConstants

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String _message = '';

  // ฟังก์ชันสำหรับทำการ login
  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/login'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String fullName = responseData['full_name'];
        // **แก้ไขตรงนี้**: รับ current_chapter และ current_route_id โดยตรงจาก Backend
        int currentChapter = responseData['current_chapter'] ?? 1; // Default to 1 if null
        int currentRouteID = responseData['current_route_id'] ?? 1; // Default to 1 if null

        setState(() {
          _message = 'เข้าสู่ระบบสำเร็จ!';
        });

        // นำทางไปยัง WelcomePage พร้อมส่งข้อมูลความคืบหน้า (int)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(
              fullName: fullName,
              username: usernameController.text,
              currentChapter: currentChapter, // ส่ง currentChapter
              currentRouteID: currentRouteID, // ส่ง currentRouteID
            ),
          ),
        );
      } else {
        setState(() {
          _message = 'เข้าสู่ระบบไม่สำเร็จ: ${jsonDecode(response.body)['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
      print('Login error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(180.0),
          child: Column(
            children: [
              const Text(
                'Welcome to Program',
                style: TextStyle(
                  color: Color.fromARGB(255, 17, 83, 3),
                  fontSize: 40,
                ),
              ),
              const Text(
                'Vape No More',
                style: TextStyle(
                  color: Color.fromARGB(255, 2, 82, 13),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'ฉลาดรู้เท่าทันบุหรี่ไฟฟ้า',
                style: TextStyle(
                  color: Color.fromARGB(255, 5, 82, 16),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/login1.png', height: 200),
                const SizedBox(width: 20),
                Image.asset('assets/images/login2.png', height: 300),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : loginUser,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login'),
            ),
            const SizedBox(height: 20),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(color: _message.contains('ไม่สำเร็จ') ? Colors.red : Colors.green),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
