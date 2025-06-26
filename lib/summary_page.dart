// lib/summary_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'welcome_page.dart'; // เพิ่ม: เพื่อกลับไปหน้า WelcomePage
import 'survey_page.dart'; // สำหรับปุ่มแบบสำรวจ

class SummaryPage extends StatefulWidget {
  final String username;

  SummaryPage({required this.username});

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  // State variables to hold user data
  String _fullName = '';
  int _age = 0;
  String _schoolLevel = '';
  String _school = '';
  String _status = '';
  int _currentChapter = 1;
  int _currentRouteID = 1;
  // Map เพื่อเก็บคะแนนรวมและคะแนนบทเรียนแยกตาม route_id
  Map<int, Map<String, dynamic>> _routeSummaries = {};
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
        Uri.parse(
          '${AppConstants.API_BASE_URL}/get_score?username=${widget.username}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _fullName = data['full_name'] ?? 'N/A';
          _age = data['age'] ?? 0; // แก้เป็น 'age' ตาม Backend
          _schoolLevel = data['school_level'] ?? 'N/A';
          _school = data['school'] ?? 'N/A';
          _status = data['status'] ?? 'N/A';
          _currentChapter = data['current_chapter'] ?? 1;
          _currentRouteID = data['current_route_id'] ?? 1;

          // แปลง route_summaries จาก dynamic map เป็น Map<int, Map<String, dynamic>>
          if (data['route_summaries'] != null) {
            _routeSummaries = (data['route_summaries'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                int.parse(key), // แปลง key string เป็น int
                Map<String, dynamic>.from(value), // แปลง value ให้เป็น Map<String, dynamic>
              ),
            );
          } else {
            _routeSummaries = {};
          }
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
      print('Error fetching user data: $e');
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
                        _buildInfoRow('สถานะ:', _status),
                        const SizedBox(height: 30),
                        const Text(
                          'คะแนนตามเส้นทาง:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _routeSummaries.isEmpty
                            ? const Text('ยังไม่มีข้อมูลคะแนนสำหรับเส้นทางใดๆ')
                            : Column(
                                children: _routeSummaries.entries.map((entry) {
                                  int routeId = entry.key;
                                  Map<String, dynamic> summary = entry.value;
                                  int totalScore = summary['total_score'] ?? 0;
                                  Map<String, int> chapterScores =
                                      Map<String, int>.from(summary['chapter_scores'] ?? {});

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'เส้นทางที่ $routeId: คะแนนรวม $totalScore',
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text('คะแนนแต่ละบท:', style: TextStyle(fontWeight: FontWeight.w600)),
                                          ...chapterScores.entries.map((chapEntry) {
                                            return Text(
                                              '  บทที่ ${chapEntry.key}: ${chapEntry.value} คะแนน',
                                              style: const TextStyle(fontSize: 16),
                                            );
                                          }).toList(),
                                        ],
                                      ),
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
                                  currentChapter: _currentChapter,
                                  currentRouteID: _currentRouteID,
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
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SurveyPage()),
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
