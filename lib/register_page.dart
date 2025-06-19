import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final schoolController = TextEditingController();
  final schoolLevelController = TextEditingController();

  String _selectedStatus = 'Teacher';
  bool _isLoading = false;
  String _message = '';

  Future<void> registerUser() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final response = await http.post(
      Uri.parse('https://apiwebmoss.roverautonomous.com/register'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'username': usernameController.text,
        'password': passwordController.text,
        'full_name': fullNameController.text,
        'old': int.tryParse(ageController.text) ?? 0,
        'school': schoolController.text,
        'status': _selectedStatus,
        'school_level': _selectedStatus == 'Student'
            ? schoolLevelController.text
            : '', // ส่งค่าว่างถ้าเป็นครู
      }),
    );

    setState(() {
      _isLoading = false;
      _message = response.statusCode == 201
          ? 'User registered successfully'
          : 'Registration failed: ${response.body}';
    });
  }

  void _showLevelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("กรุณากรอกระดับชั้น"),
          content: TextField(
            controller: schoolLevelController,
            decoration: InputDecoration(labelText: 'ระดับชั้น'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username (ชื่อผู้ใช้งาน)',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password (รหัสผ่าน)'),
              obscureText: true,
            ),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(labelText: 'Full Name (ชื่อ-สกุล)'),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Age (อายุ)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: schoolController,
              decoration: InputDecoration(labelText: 'School (โรงเรียน)'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text("Status (สถานะ): "),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: <String>['Teacher', 'Student']
                      .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value == 'Teacher' ? 'ครู' : 'นักเรียน'),
                        );
                      })
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                        if (value == 'Student') {
                          _showLevelDialog();
                        } else {
                          schoolLevelController.clear();
                        }
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : registerUser,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
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
