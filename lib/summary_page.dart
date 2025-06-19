import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        Uri.parse('https://apiwebmoss.roverautonomous.com/get_score?username=${widget.username}'), // <-- ใช้ URL ของ Go backend ที่รันอยู่
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _fullName = data['full_name'] ?? 'N/A';
          _totalScore = data['total_score'] ?? 0;
          _age = data['old'] ?? 0;
          _schoolLevel = data['school_level'] ?? 'N/A';
          _school = data['school'] ?? 'N/A';
          _chapterScores = Map<String, dynamic>.from(data['chapter_score'] ?? {}); // ดึงคะแนนรายบท
          
          // สร้างข้อความสถานะ
          if (_schoolLevel == 'ครู') {
            _status = 'ครู';
          } else if (_schoolLevel == 'นักเรียน') {
            _status = 'นักเรียน ชั้น $_schoolLevel จาก $_school';
          } else {
            _status = 'อื่นๆ: $_schoolLevel';
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'ไม่สามารถดึงข้อมูลผู้ใช้ได้: ${jsonDecode(response.body)['message']}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
        _isLoading = false;
      });
    }
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
                : SingleChildScrollView( // ใช้ SingleChildScrollView เพื่อให้เลื่อนได้หากเนื้อหายาว
                    child: Padding(
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
                          _buildInfoRow("คะแนนรวมทั้งสิ้น:", _totalScore.toString()),
                          const SizedBox(height: 30),
                          
                          // ส่วนแสดงคะแนนแต่ละบท
                          if (_chapterScores.isNotEmpty) ...[
                            const Text(
                              "คะแนนรายบท:",
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
                                // แก้ไขจาก Colors.blueAccent.shade100 เป็น Colors.blue[100]
                                border: Border.all(color: Colors.blue[100]!), 
                                borderRadius: BorderRadius.circular(10),
                                // แก้ไขจาก Colors.blueAccent.shade50 เป็น Colors.blue[50]
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
                            ),
                          ],
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () {
                              // กลับไปยังหน้าก่อนหน้า หรือหน้าแรก
                              Navigator.popUntil(context, (route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "กลับหน้าหลัก",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
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
