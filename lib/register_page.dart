// lib/register_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart'; // นำเข้า AppConstants

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

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/register'),
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
            ? 'ลงทะเบียนสำเร็จ!'
            : 'ลงทะเบียนไม่สำเร็จ: ${jsonDecode(response.body)['message']}';
      });

      if (response.statusCode == 201) {
        // Optionally navigate to login page or show success and allow manual navigation
        Navigator.pop(context); // กลับไปหน้า Login
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
      print('Registration error: $e');
    }
  }

  void _showLevelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("กรุณากรอกระดับชั้น"),
          content: TextField(
            controller: schoolLevelController,
            decoration: const InputDecoration(labelText: 'ระดับชั้น'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลงทะเบียน')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username (ชื่อผู้ใช้งาน)',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password (รหัสผ่าน)'),
              obscureText: true,
            ),
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name (ชื่อ-สกุล)'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age (อายุ)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: schoolController,
              decoration: const InputDecoration(labelText: 'School (โรงเรียน)'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Status (สถานะ): "),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: <String>['Teacher', 'Student']
                      .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value == 'Teacher' ? 'ครู' : 'นักเรียน'),
                        );
                      }).toList(),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : registerUser,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Register'),
            ),
            const SizedBox(height: 20),
            Text(_message, textAlign: TextAlign.center, style: TextStyle(color: _message.contains('ไม่สำเร็จ') ? Colors.red : Colors.green)),
          ],
        ),
      ),
    );
  }
}
