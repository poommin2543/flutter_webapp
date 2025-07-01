// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'register_page.dart';
import 'welcome_page.dart';
import 'constants.dart'; // AppConstants

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 1.6),
      ),
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

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fullName = data['full_name'];
        final currentChapter = data['current_chapter'] ?? 1;
        final currentRouteID = data['current_route_id'] ?? 1;

        setState(() => _message = 'เข้าสู่ระบบสำเร็จ!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WelcomePage(
              fullName: fullName,
              username: usernameController.text,
              currentChapter: currentChapter,
              currentRouteID: currentRouteID,
            ),
          ),
        );
      } else {
        final err = jsonDecode(response.body)['message'];
        setState(() => _message = 'เข้าสู่ระบบไม่สำเร็จ: $err');
      }
    } catch (e) {
      setState(() => _message = 'เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 Background Image
          Image.asset(
            'assets/images/login.png',
            fit: BoxFit.cover, // ปรับให้เต็มจอแบบพอดี
          ),

          // 🔹 Login Form Overlay (มีพื้นหลังโปร่ง)
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 500),
                      Card(
                        color: Colors.white.withOpacity(
                          0.9,
                        ), // โปร่งแสงเล็กน้อย
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username (กรอกชื่อผู้ใช้งาน)',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password (กรอกรหัสผ่าน)',
                                ),
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : loginUser,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Login (ลงชื่อเข้าใช้งาน)',
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RegisterPage(),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'Register (สมัครเพื่อเข้าใช้งาน)',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_message.isNotEmpty)
                        Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _message.contains('ไม่สำเร็จ')
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
