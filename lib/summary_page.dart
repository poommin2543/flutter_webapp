// lib/summary_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'main.dart'; // สำหรับกลับไป LoginPage (อาจเปลี่ยนเป็น WelcomePage)
import 'welcome_page.dart'; // เพิ่ม: เพื่อกลับไปหน้า WelcomePage
import 'survey_page.dart'; // ตรวจสอบว่ามีบรรทัดนี้

class SummaryPage extends StatefulWidget {
  final String username;

  SummaryPage({required this.username});

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  // State variables to hold user data
  String _fullName = '';
  int _totalScore = 0;
  int _age = 0;
  String _schoolLevel = '';
  String _school = '';
  String _status = ''; // เพื่อรวมข้อมูลสถานะ
  Map<String, dynamic> _chapterScores = {}; // เพิ่มสำหรับเก็บคะแนนรายบท
  bool _isLoading = true;
  String _errorMessage = '';

  // สำหรับเก็บ current_chapter และ current_route_id
  int _currentChapter = 1;
  int _currentRouteID = 1;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Function to fetch user data from the backend
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${AppConstants.API_BASE_URL}/get_score?username=${widget.username}',
        ), // <-- ใช้ URL ของ Go backend ที่รันอยู่
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _fullName = data['full_name'] ?? 'N/A';
          _totalScore = data['total_score'] ?? 0;
          _age = data['old'] ?? 0;
          _schoolLevel = data['school_level'] ?? 'N/A';
          _school = data['school'] ?? 'N/A';
          _status = data['status'] ?? 'N/A'; // ดึง status
          _chapterScores = Map<String, dynamic>.from(
              data['chapter_score'] ?? {}); // แปลงเป็น Map<String, dynamic>
          _currentChapter = data['current_chapter'] ?? 1; // ดึง current_chapter
          _currentRouteID = data['current_route_id'] ?? 1; // ดึง current_route_id
        });
      } else {
        setState(() {
          _errorMessage =
              'ไม่สามารถดึงข้อมูลผู้ใช้ได้: ${response.statusCode} - ${response.body}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สรุปข้อมูลผู้ใช้'),
        automaticallyImplyLeading: false, // ซ่อนปุ่มย้อนกลับ
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage.isNotEmpty
                ? Text(_errorMessage)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'ข้อมูลโปรไฟล์และคะแนน',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow('ชื่อ-นามสกุล:', _fullName),
                        _buildInfoRow('Username:', widget.username),
                        _buildInfoRow('อายุ:', _age.toString()),
                        _buildInfoRow('ระดับชั้น:', _schoolLevel),
                        _buildInfoRow('โรงเรียน:', _school),
                        _buildInfoRow('สถานะ:', _status), // แสดง status
                        _buildInfoRow('คะแนนรวม:', _totalScore.toString()),
                        const SizedBox(height: 20),
                        const Text(
                          'คะแนนแต่ละบทเรียน:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _chapterScores.isEmpty
                            ? const Text('ยังไม่มีคะแนนบทเรียน')
                            : Column(
                                children: _chapterScores.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      'บทที่ ${entry.key}: ${entry.value} คะแนน',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  );
                                }).toList(),
                              ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WelcomePage(
                                  username: widget.username,
                                  fullName: _fullName,
                                  currentChapter: _currentChapter, // ส่ง currentChapter
                                  currentRouteID: _currentRouteID, // ส่ง currentRouteID
                                ),
                              ),
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
                            "กลับหน้าหลัก",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // ปุ่มสำหรับทำแบบประเมิน (Survey) - ถ้ามีแยกต่างหาก
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SurveyPage()), 
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
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
                            "ทำแบบสำรวจ",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
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
}
