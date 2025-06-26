import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'register_page.dart'; // นำเข้าหน้า Register
// import 'MainChapter.dart';
import 'welcome_page.dart';

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

    final response = await http.post(
      // Uri.parse('http://127.0.0.1:8080/login'), // หรือ IP Address ของเครื่อง
      Uri.parse(
        'https://apiwebmoss.roverautonomous.com/login',
      ), // หรือ IP Address ของเครื่อง
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'username': usernameController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = 'Login successful';
      });
      // คุณสามารถไปหน้าใหม่ หรือเก็บข้อมูลการเข้าสู่ระบบได้ที่นี่
      // เมื่อ login สำเร็จ, นำผู้ใช้ไปที่หน้า TestPage
      final responseData = jsonDecode(response.body);

      String fullName = responseData['full_name']; // ดึง full_name จาก response
      // int currentChapter = responseData['current_chapter'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomePage(
            fullName: fullName,
            username: usernameController.text,
            // currentUnlockedChapter: currentChapter,
          ),
        ),
      );
    } else {
      setState(() {
        _message = 'Invalid email or password';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(180.0),
          child: Column(
            children: [
              Text(
                'Welcome to Program',
                style: TextStyle(
                  color: const Color.fromARGB(255, 17, 83, 3),
                  fontSize: 40,
                ),
              ),
              Text(
                'Vape No More',
                style: TextStyle(
                  color: const Color.fromARGB(255, 2, 82, 13),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ฉลาดรู้เท่าทันบุหรี่ไฟฟ้า',
                style: TextStyle(
                  color: const Color.fromARGB(255, 5, 82, 16),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20), // เว้นช่อง
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/login1.png', height: 200),
                SizedBox(width: 20),
                //Image.asset('assets/images/login1.png', height: 100),
                Image.asset('assets/images/login2.png', height: 300),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : loginUser, // Disable button while loading
              child: _isLoading ? CircularProgressIndicator() : Text('Login'),
            ),

            SizedBox(height: 20),
            Text(_message),

            // ปุ่ม Register ที่เชื่อมไปยังหน้า RegisterPage
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
