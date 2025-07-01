// lib/summary_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart'; // ตรวจสอบให้แน่ใจว่าพาธนี้ถูกต้อง

class SummaryPage extends StatefulWidget {
  final String username;

  SummaryPage({required this.username});

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  List<Map<String, dynamic>> _leaderboardData = [];
  String _errorMessage = '';
  bool _isLoading = true;
  int?
  _selectedRouteId; // เพิ่มตัวแปรสถานะสำหรับเก็บ routeId ที่เลือก (null คือ All Routes)

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // ล้างข้อความข้อผิดพลาดก่อนเริ่มโหลด
    });

    try {
      String url = '${AppConstants.API_BASE_URL}/leaderboard';
      if (_selectedRouteId != null) {
        url +=
            '?route_id=$_selectedRouteId'; // เพิ่ม query parameter ถ้ามีการเลือก routeId
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);

        if (responseBody is List) {
          setState(() {
            _leaderboardData = List<Map<String, dynamic>>.from(
              responseBody.map((item) {
                return {
                  'username':
                      item['username']?.toString() ?? 'ไม่ระบุชื่อผู้ใช้',
                  'score': (item['total_score'] is int)
                      ? item['total_score']
                      : (int.tryParse(item['total_score']?.toString() ?? '0') ??
                            0), // ใช้ total_score
                };
              }),
            );
            // เรียงลำดับจากคะแนนสูงสุดไปต่ำสุด
            _leaderboardData.sort((a, b) => b['score'].compareTo(a['score']));
          });
        } else if (responseBody is Map &&
            responseBody.containsKey('leaderboard') &&
            responseBody['leaderboard'] is List) {
          setState(() {
            _leaderboardData = List<Map<String, dynamic>>.from(
              responseBody['leaderboard'].map((item) {
                return {
                  'username':
                      item['username']?.toString() ?? 'ไม่ระบุชื่อผู้ใช้',
                  'score': (item['total_score'] is int)
                      ? item['total_score']
                      : (int.tryParse(item['total_score']?.toString() ?? '0') ??
                            0), // ใช้ total_score
                };
              }),
            );
            // เรียงลำดับจากคะแนนสูงสุดไปต่ำสุด
            _leaderboardData.sort((a, b) => b['score'].compareTo(a['score']));
          });
        } else if (responseBody is Map &&
            responseBody.containsKey('message') &&
            responseBody['message'] is String) {
          setState(() {
            _errorMessage =
                'ข้อผิดพลาดจากเซิร์ฟเวอร์: ${responseBody['message']}';
            _leaderboardData = []; // เคลียร์ข้อมูลเดิม
          });
        } else {
          setState(() {
            _errorMessage =
                'รูปแบบข้อมูลที่ได้รับจากเซิร์ฟเวอร์ไม่ถูกต้อง: ${response.body}';
            _leaderboardData = []; // เคลียร์ข้อมูลเดิม
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'ไม่สามารถโหลดข้อมูลกระดานผู้นำได้: สถานะ ${response.statusCode} - ${response.body}';
          _leaderboardData = []; // เคลียร์ข้อมูลเดิม
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${e.toString()}';
        _leaderboardData = []; // เคลียร์ข้อมูลเดิม
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
        title: const Text('กระดานผู้นำ'),
        automaticallyImplyLeading: false, // ซ่อนปุ่มย้อนกลับ
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<int?>(
              value: _selectedRouteId,
              hint: const Text('เลือกเส้นทาง'),
              items: <DropdownMenuItem<int?>>[
                const DropdownMenuItem<int?>(
                  value: null, // null สำหรับ "ทุกเส้นทาง"
                  child: Text('ทุกเส้นทาง'),
                ),
                for (int i = 1; i <= 3; i++) // สมมติว่ามี 3 เส้นทาง
                  DropdownMenuItem<int?>(
                    value: i,
                    child: Text('เส้นทางที่ $i'),
                  ),
              ],
              onChanged: (int? newValue) {
                setState(() {
                  _selectedRouteId = newValue;
                  _fetchLeaderboardData(); // โหลดข้อมูลใหม่เมื่อเปลี่ยนเส้นทาง
                });
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // แสดงวงกลมโหลด
          : _errorMessage
                .isNotEmpty // ถ้ามีข้อความข้อผิดพลาด
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ), // ไอคอนข้อผิดพลาด
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchLeaderboardData, // ปุ่มลองโหลดใหม่
                      child: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              ),
            )
          : _leaderboardData
                .isEmpty // ถ้าไม่มีข้อมูลกระดานผู้นำ
          ? Center(
              child: Text(
                'ไม่มีข้อมูลกระดานผู้นำสำหรับ${_selectedRouteId == null ? 'ทุกเส้นทาง' : 'เส้นทางที่ $_selectedRouteId'} ในขณะนี้',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _leaderboardData.length,
              itemBuilder: (context, index) {
                final user = _leaderboardData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        '${index + 1}', // แสดงอันดับ
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      user['username'] ?? 'ไม่ระบุชื่อผู้ใช้',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    trailing: Text(
                      'คะแนน: ${user['score']}', // แสดงคะแนน
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // นำทางกลับสู่หน้าหลัก
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
        label: const Text('กลับสู่หน้าหลัก'),
        icon: const Icon(Icons.home),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
