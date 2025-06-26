// lib/summary_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart'; // นำเข้า AppConstants
import 'survey_page.dart'; // นำเข้า SurveyPage

class SummaryPage extends StatefulWidget {
  final String username;

  SummaryPage({required this.username});

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String _fullName = '';
  int _totalScore = 0;
  int _age = 0;
  String _schoolLevel = '';
  String _school = '';
  String _status = '';
  Map<String, dynamic> _chapterScores = {};
  List<dynamic> _chapterAttempts = []; // เพิ่มสำหรับเก็บประวัติการทำแต่ละครั้ง
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
          _chapterScores = Map<String, dynamic>.from(userData['chapter_score'] ?? {});
          _chapterAttempts = attemptsData['attempts'] ?? [];

          // สร้างข้อความสถานะ
          if (_schoolLevel == 'Teacher') { // Backend ส่ง 'Teacher'/'Student' มา
            _status = 'ครู';
          } else if (_schoolLevel == 'Student') {
            _status = 'นักเรียน ชั้น $_schoolLevel จาก $_school';
          } else {
            _status = 'อื่นๆ: $_schoolLevel';
          }
        });
      } else {
        setState(() {
          _errorMessage = 'ไม่สามารถดึงข้อมูลผู้ใช้ได้: ${jsonDecode(userResponse.body)['message']} หรือ ประวัติการทำ: ${jsonDecode(attemptsResponse.body)['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
      print('Error fetching user data and attempts: $e');
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
          Text(
            value,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สรุปผลคะแนน'),
        automaticallyImplyLeading: false, // ปิดปุ่มย้อนกลับ
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "ยินดีด้วย!",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        _buildInfoRow("ชื่อ-สกุล:", _fullName),
                        _buildInfoRow("สถานะ:", _status),
                        _buildInfoRow("อายุ:", _age.toString()),
                        _buildInfoRow(
                          "คะแนนรวมทั้งสิ้น:",
                          _totalScore.toString(),
                        ),
                        const SizedBox(height: 30),

                        // ส่วนแสดงคะแนนที่ดีที่สุดแต่ละบท
                        if (_chapterScores.isNotEmpty) ...[
                          const Text(
                            "คะแนนที่ดีที่สุดรายบท:",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue[100]!),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue[50],
                            ),
                            child: Column(
                              children: _chapterScores.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'บทที่ ${entry.key}:',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                          ),
                        ],
                        const SizedBox(height: 30),
                        // ส่วนแสดงประวัติการทำแต่ละครั้ง
                        if (_chapterAttempts.isNotEmpty) ...[
                          const Text(
                            "ประวัติการทำแต่ละครั้ง:",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange[100]!),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.orange[50],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true, // ทำให้ ListView ใช้พื้นที่เท่าที่จำเป็น
                              physics: const NeverScrollableScrollPhysics(), // ปิดการ scroll ของ ListView นี้
                              itemCount: _chapterAttempts.length,
                              itemBuilder: (context, index) {
                                final attempt = _chapterAttempts[index];
                                final timestamp = DateTime.parse(attempt['attempt_time']);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'เส้นทางที่ ${attempt['route_id']}, บทที่ ${attempt['chapter_number']}:',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        '${attempt['score']} คะแนน (${timestamp.toLocal().toString().split('.')[0]})',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SurveyPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "ทำแบบประเมิน",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // กลับไปยังหน้า WelcomePage
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
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
