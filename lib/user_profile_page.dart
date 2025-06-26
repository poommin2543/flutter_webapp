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
  int _age = 0;
  String _schoolLevel = '';
  String _school = '';
  String _status = '';
  int _currentChapter = 1;
  int _currentRouteId = 1;
  Map<int, RouteScoreSummaryDisplay> _routeSummaries = {}; // เปลี่ยนเป็น Map<int, RouteScoreSummaryDisplay>
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
      // ดึงข้อมูลผู้ใช้และคะแนนรวม/รายบท (ซึ่งตอนนี้จะมาในรูป route_summaries)
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

        print('UserProfilePage Raw Backend Data: $userData'); // Debug print for raw data

        setState(() {
          _fullName = userData['full_name'] ?? 'N/A';
          _age = userData['age'] ?? 0; // เปลี่ยนจาก 'old' เป็น 'age' ให้ตรงกับ backend
          _schoolLevel = userData['school_level'] ?? 'N/A';
          _school = userData['school'] ?? 'N/A';
          _currentChapter = userData['current_chapter'] ?? 1;
          _currentRouteId = userData['current_route_id'] ?? 1;

          // Parse route_summaries
          _routeSummaries = {}; // Clear previous data
          if (userData['route_summaries'] != null) {
            final Map<String, dynamic> rawRouteSummaries =
                Map<String, dynamic>.from(userData['route_summaries']);
            print('UserProfilePage Raw Route Summaries: $rawRouteSummaries'); // Debug print

            rawRouteSummaries.forEach((key, value) {
              final int? routeId = int.tryParse(key);
              if (routeId != null && value is Map<String, dynamic>) {
                final int totalScore = value['total_score'] ?? 0;
                final Map<String, int> chapterScores = {};
                if (value['chapter_scores'] != null) {
                  (value['chapter_scores'] as Map<String, dynamic>).forEach((chapKey, chapValue) {
                    // Filter chapter numbers to be between 1 and 5 (inclusive)
                    if (int.tryParse(chapKey) != null &&
                        int.parse(chapKey) >= 1 && int.parse(chapKey) <= 5) {
                      chapterScores[chapKey] = chapValue as int;
                    }
                  });
                }
                _routeSummaries[routeId] = RouteScoreSummaryDisplay(
                  totalScore: totalScore,
                  chapterScores: chapterScores,
                );
              }
            });
            print('UserProfilePage Parsed Route Summaries: $_routeSummaries'); // Debug print
          } else {
            print('UserProfilePage route_summaries is null or empty.');
          }

          _chapterAttempts = attemptsData['attempts'] ?? [];

          // การกำหนดสถานะจาก school_level (Backend ควรส่ง 'Teacher' หรือ 'Student' มา)
          // ใช้ userData['status'] แทน userData['school_level'] เพื่อความถูกต้อง
          if (userData['status'] == 'Teacher') {
            _status = 'ครู';
          } else if (userData['status'] == 'Student') {
            _status = 'นักเรียน (ชั้น ${_schoolLevel} จาก ${_school})';
          } else {
            _status = userData['status'] ?? 'N/A'; // ค่าอื่นๆ หรือ N/A
          }
        });
      } else {
        _errorMessage = 'ไม่สามารถดึงข้อมูลผู้ใช้ได้: ${jsonDecode(userResponse.body)['message'] ?? 'Unknown error'}';
        if (attemptsResponse.statusCode != 200) {
          _errorMessage += ' หรือ ประวัติการทำ: ${jsonDecode(attemptsResponse.body)['message'] ?? 'Unknown error'}';
        }
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
      print('Resetting scores for username: ${widget.username}');
      final requestBody = jsonEncode({'username': widget.username});
      print('Reset score request body: $requestBody');

      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/reset_score'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
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
    // Calculate overall total score from all routes
    int overallTotalScore = _routeSummaries.values.fold(0, (sum, summary) => sum + summary.totalScore);

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
                        const Divider(),
                        const SizedBox(height: 20),
                        Text(
                          "คะแนนรวมทั้งหมด: $overallTotalScore", // แสดงคะแนนรวมทั้งหมด
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "คะแนนแยกตามเส้นทาง:", // เปลี่ยนข้อความเป็น "คะแนนแยกตามเส้นทาง"
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_routeSummaries.isNotEmpty)
                          Column(
                            children: _routeSummaries.entries.map((entry) {
                              int routeId = entry.key;
                              RouteScoreSummaryDisplay summary = entry.value;

                              // Ensure chapter scores are displayed in a sorted order if needed
                              final sortedChapterEntries = summary.chapterScores.entries.toList()
                                ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'เส้นทางที่ $routeId: คะแนนรวม ${summary.totalScore} คะแนน',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text('คะแนนแต่ละบท:', style: TextStyle(fontWeight: FontWeight.w600)),
                                      if (sortedChapterEntries.isNotEmpty)
                                        ...sortedChapterEntries.map((chapEntry) {
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 10, top: 2),
                                            child: Text(
                                              '  บทที่ ${chapEntry.key}: ${chapEntry.value} คะแนน',
                                              style: const TextStyle(fontSize: 15),
                                            ),
                                          );
                                        }).toList()
                                      else
                                        const Padding(
                                          padding: EdgeInsets.only(left: 10, top: 2),
                                          child: Text('  ยังไม่มีคะแนนสำหรับบทเรียนในเส้นทางนี้'),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const Text('ยังไม่มีข้อมูลคะแนนสำหรับเส้นทางใดๆ'),
                        const SizedBox(height: 30),
                        const Divider(),
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
                            Navigator.pop(context); // กลับไปยังหน้า WelcomePage (หรือ MainChapterPage)
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

// Helper class เพื่อช่วยในการแสดงผล RouteScoreSummary
// คลาสนี้ควรจะอยู่ที่นี่หรือในไฟล์ constants.dart ที่สามารถเข้าถึงได้
class RouteScoreSummaryDisplay {
  final int totalScore;
  final Map<String, int> chapterScores;

  RouteScoreSummaryDisplay({
    required this.totalScore,
    required this.chapterScores,
  });

  @override
  String toString() {
    return 'Total Score: $totalScore, Chapter Scores: $chapterScores';
  }
}
