// lib/leaderboard_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart'; // นำเข้า AppConstants

class LeaderboardPage extends StatefulWidget {
  final String username;
  final String fullName; // เพิ่ม fullName เข้ามา

  const LeaderboardPage({Key? key, required this.username, required this.fullName}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int? _selectedRouteId; // เพิ่มตัวแปรสถานะสำหรับเก็บ routeId ที่เลือก (null คือ All Routes)

  Map<String, dynamic>? _currentUserRank; // สำหรับเก็บข้อมูลอันดับของผู้ใช้ปัจจุบัน

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // ล้างข้อความข้อผิดพลาดก่อนเริ่มโหลด
      _currentUserRank = null; // ล้างข้อมูลอันดับผู้ใช้ปัจจุบัน
    });

    try {
      String url = '${AppConstants.API_BASE_URL}/leaderboard';
      if (_selectedRouteId != null) {
        url += '?route_id=$_selectedRouteId'; // เพิ่ม query parameter ถ้ามีการเลือก routeId
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);

        List<Map<String, dynamic>> fetchedData = [];

        // ตรวจสอบรูปแบบการตอบกลับจาก Backend
        if (responseBody is List) {
          fetchedData = List<Map<String, dynamic>>.from(responseBody.map((item) {
            return {
              'username': item['username']?.toString() ?? 'ไม่ระบุชื่อผู้ใช้',
              'full_name': item['full_name']?.toString() ?? '', // ตรวจสอบว่า Backend ส่ง full_name มาด้วย
              'score': (item['total_score'] is int) ? item['total_score'] : (int.tryParse(item['total_score']?.toString() ?? '0') ?? 0),
            };
          }));
        } else if (responseBody is Map && responseBody.containsKey('leaderboard') && responseBody['leaderboard'] is List) {
          fetchedData = List<Map<String, dynamic>>.from(responseBody['leaderboard'].map((item) {
            return {
              'username': item['username']?.toString() ?? 'ไม่ระบุชื่อผู้ใช้',
              'full_name': item['full_name']?.toString() ?? '', // ตรวจสอบว่า Backend ส่ง full_name มาด้วย
              'score': (item['total_score'] is int) ? item['total_score'] : (int.tryParse(item['total_score']?.toString() ?? '0') ?? 0),
            };
          }));
        } else if (responseBody is Map && responseBody.containsKey('message') && responseBody['message'] is String) {
          setState(() {
            _errorMessage = 'ข้อผิดพลาดจากเซิร์ฟเวอร์: ${responseBody['message']}';
          });
        } else {
          setState(() {
            _errorMessage = 'รูปแบบข้อมูลที่ได้รับจากเซิร์ฟเวอร์ไม่ถูกต้อง: ${response.body}';
          });
        }

        // เรียงลำดับจากคะแนนสูงสุดไปต่ำสุด
        fetchedData.sort((a, b) => b['score'].compareTo(a['score']));

        // ค้นหาอันดับของผู้ใช้ปัจจุบัน
        for (int i = 0; i < fetchedData.length; i++) {
          if (fetchedData[i]['username'] == widget.username) {
            _currentUserRank = {
              'rank': i + 1,
              'username': fetchedData[i]['username'],
              'full_name': fetchedData[i]['full_name'],
              'score': fetchedData[i]['score'],
            };
            break; // พบแล้ว ออกจากลูป
          }
        }

        setState(() {
          _leaderboardData = fetchedData;
        });

      } else {
        setState(() {
          _errorMessage = 'ไม่สามารถโหลดข้อมูลกระดานผู้นำได้: สถานะ ${response.statusCode} - ${response.body}';
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
                  _fetchLeaderboard(); // โหลดข้อมูลใหม่เมื่อเปลี่ยนเส้นทาง
                });
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // แสดงวงกลมโหลด
          : _errorMessage.isNotEmpty // ถ้ามีข้อความข้อผิดพลาด
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 50), // ไอคอนข้อผิดพลาด
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchLeaderboard, // ปุ่มลองโหลดใหม่
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    ),
                  ),
                )
              : _leaderboardData.isEmpty // ถ้าไม่มีข้อมูลกระดานผู้นำ
                  ? Center(child: Text('ไม่มีข้อมูลกระดานผู้นำสำหรับ${_selectedRouteId == null ? 'ทุกเส้นทาง' : 'เส้นทางที่ $_selectedRouteId'} ในขณะนี้'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'ผู้เล่นคะแนนสูงสุด',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent),
                          ),
                          const SizedBox(height: 20),
                          // แสดงอันดับของผู้ใช้ปัจจุบัน
                          if (_currentUserRank != null)
                            Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 6, // ยกให้สูงกว่าปกติ
                              color: Colors.blue.shade50, // สีพื้นหลังเพื่อเน้น
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(color: Colors.blueAccent, width: 2)), // เพิ่มขอบ
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'อันดับของคุณ:',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${_currentUserRank!['rank']}. ${ _currentUserRank!['full_name'].isNotEmpty ? _currentUserRank!['full_name'] : _currentUserRank!['username']}', // แสดงชื่อนามสกุล ถ้ามี
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.blueGrey),
                                        ),
                                        Text(
                                          '${_currentUserRank!['score']} คะแนน',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 10), // เว้นวรรคหลังจากอันดับผู้ใช้ปัจจุบัน

                          Expanded(
                            child: ListView.builder(
                              itemCount: _leaderboardData.length,
                              itemBuilder: (context, index) {
                                final user = _leaderboardData[index];
                                // ไม่แสดงผู้ใช้ปัจจุบันซ้ำในรายการหลัก หากแสดงเป็น Card แยกแล้ว
                                if (_currentUserRank != null && user['username'] == widget.username) {
                                  return const SizedBox.shrink(); // ซ่อนรายการนี้
                                }
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${index + 1}.',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user['full_name'].isNotEmpty ? user['full_name'] : user['username'] ?? 'Unknown', // แสดง full_name ก่อน ถ้าไม่ก็แสดง username
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              if (user['full_name'].isNotEmpty && user['full_name'] != user['username']) // ถ้ามี full_name และไม่ซ้ำกับ username
                                                Text(
                                                  '(${user['username']})', // แสดง username วงเล็บเล็กๆ
                                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${user['score'] ?? 0} คะแนน',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // กลับไปยังหน้า WelcomePage
                            },
                            child: const Text('กลับหน้าหลัก'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
