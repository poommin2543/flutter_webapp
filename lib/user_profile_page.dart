// lib/user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart'; // นำเข้า AppConstants

class UserProfilePage extends StatefulWidget {
  final String username;

  UserProfilePage({required this.username});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _fullName = '';
  int _totalScore = 0;
  int _age = 0;
  String _schoolLevel = '';
  String _school = '';
  String _status = '';
  int _currentChapter = 1;
  int _currentRouteId = 1;
  Map<String, dynamic> _chapterScores = {};
  List<dynamic> _chapterAttempts = []; // สำหรับเก็บประวัติการทำแต่ละครั้ง
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndScores();
  }

  Future<void> _fetchUserDataAndScores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // ดึงข้อมูลผู้ใช้และคะแนนรวม/รายบท
      final userResponse = await http.get(
        Uri.parse('${AppConstants.API_BASE_URL}/get_score?username=${widget.username}'),
      );

      // ดึงประวัติการทำบทเรียน
      final attemptsResponse = await http.get(
        Uri.parse('${AppConstants.API_BASE_URL}/get_chapter_attempts?username=${widget.username}'),
      );

      if (userResponse.statusCode == 200 && attemptsResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);
        final attemptsData = jsonDecode(attemptsResponse.body);

        setState(() {
          _fullName = userData['full_name'] ?? 'N/A';
          _totalScore = userData['total_score'] ?? 0;
          _age = userData['old'] ?? 0;
          _schoolLevel = userData['school_level'] ?? 'N/A';
          _school = userData['school'] ?? 'N/A';
          _currentChapter = userData['current_chapter'] ?? 1;
          _currentRouteId = userData['current_route_id'] ?? 1;
          _chapterScores = Map<String, dynamic>.from(userData['chapter_score'] ?? {});
          _chapterAttempts = attemptsData['attempts'] ?? [];

          if (_schoolLevel == 'Teacher') { // Backend ส่ง 'Teacher'/'Student' มา
            _status = 'ครู';
          } else if (_schoolLevel == 'Student') {
            _status = 'นักเรียน ชั้น $_schoolLevel จาก $_school';
          } else {
            _status = 'อื่นๆ: $_schoolLevel';
          }
        });
      } else {
        _errorMessage = 'ไม่สามารถดึงข้อมูลผู้ใช้ได้: ${jsonDecode(userResponse.body)['message']} หรือ ประวัติการทำ: ${jsonDecode(attemptsResponse.body)['message']}';
      }
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetScores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/reset_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': widget.username}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รีเซ็ตคะแนนสำเร็จ')),
        );
        _fetchUserDataAndScores(); // โหลดข้อมูลใหม่
      } else {
        setState(() {
          _errorMessage = 'รีเซ็ตคะแนนไม่สำเร็จ: ${jsonDecode(response.body)['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์ผู้ใช้'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_pin_circle,
                          color: Colors.deepPurple,
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "สวัสดี, ${widget.username}!",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow("ชื่อ-สกุล:", _fullName),
                        _buildInfoRow("อายุ:", _age.toString()),
                        _buildInfoRow("สถานะ:", _status),
                        _buildInfoRow("บทปัจจุบัน:", 'บทที่ $_currentChapter (เส้นทางที่ $_currentRouteId)'),
                        const SizedBox(height: 20),
                        Divider(),
                        const SizedBox(height: 20),
                        Text(
                          "คะแนนรวม: $_totalScore",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "คะแนนที่ดีที่สุดแต่ละบท:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_chapterScores.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue[100]!),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue[50],
                            ),
                            child: Column(
                              children: _chapterScores.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'บทที่ ${entry.key}:',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        '${entry.value} คะแนน',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        else
                          const Text('ยังไม่มีคะแนนบทเรียน'),
                        const SizedBox(height: 30),
                        Divider(),
                        const SizedBox(height: 30),
                        const Text(
                          "ประวัติการทำแต่ละครั้ง:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _chapterAttempts.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true, // ทำให้ ListView ใช้พื้นที่เท่าที่จำเป็น
                                physics: const NeverScrollableScrollPhysics(), // ปิดการ scroll ของ ListView นี้
                                itemCount: _chapterAttempts.length,
                                itemBuilder: (context, index) {
                                  final attempt = _chapterAttempts[index];
                                  final timestamp = DateTime.parse(attempt['attempt_time']);
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'เส้นทางที่ ${attempt['route_id']}, บทที่ ${attempt['chapter_number']}: ${attempt['score']} คะแนน',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'เวลา: ${timestamp.toLocal().toString().split('.')[0]}', // แสดงแค่ วว-ดด-ปป ชม:นาที:วินาที
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const Text('ยังไม่มีประวัติการทำบทเรียน'),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _resetScores,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('รีเซ็ตคะแนนทั้งหมด'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // กลับไปยังหน้า WelcomePage
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('กลับหน้าหลัก'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
