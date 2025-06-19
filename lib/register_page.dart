import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController oldController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController schoolLevelController = TextEditingController();

  bool _isLoading = false;
  String _message = '';

  // ฟังก์ชันสำหรับการสมัครสมาชิก
  Future<void> registerUser() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final response = await http.post(
      Uri.parse('https://apiwebmoss.roverautonomous.com/register'),  // เปลี่ยนเป็น URL API ของคุณ
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'username': usernameController.text,
        'password': passwordController.text,
        'full_name': fullNameController.text,
        // 'old': oldController.text,
        'old' : int.tryParse(oldController.text) ?? 0, 
        'school': schoolController.text,
        'school_level': schoolLevelController.text,
      }
      ),
      
    );
    
    if (response.statusCode == 201) {
      setState(() {
        _message = 'User registered successfully';
      });
    } else {
      setState(() {
        _message = 'Registration failed: ${response.body}';
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
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: oldController,
              decoration: InputDecoration(labelText: 'Old'),
            ),
            TextField(
              controller: schoolController,
              decoration: InputDecoration(labelText: 'School'),
            ),
            TextField(
              controller: schoolLevelController,
              decoration: InputDecoration(labelText: 'School Level'),
            ),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : registerUser,  // Disable while loading
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Register'),
            ),
            SizedBox(height: 20),
            Text(_message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
