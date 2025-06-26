// lib/chapter5.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'summary_page.dart'; // Import the new SummaryPage
import 'constants.dart'; // นำเข้า AppConstants

class Chapter5Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId; // เพิ่ม: รับ routeId เข้ามา
  final VoidCallback onFinished;

  Chapter5Page({
    required this.chapter,
    required this.username,
    required this.routeId, // กำหนดให้รับ routeId
    required this.onFinished,
  });

  @override
  _Chapter5PageState createState() => _Chapter5PageState();
}

class _Chapter5PageState extends State<Chapter5Page> {
  final TextEditingController _commentController = TextEditingController();
  String _message = '';

  final List<String> questions = [
    "การแนะนำเพื่อนที่ดีด้วยใจของเราเอง เป็นสิ่งที่มีคุณค่า?",
  ];

  final List<List<String>> options = [
    ["ใช่ ทุกประการ", "ใช่ บางประการ", "ไม่ใช่ บางประการ", "ไม่ใช่ทุกประการ"],
  ];

  final List<String> answers = ["ใช่ ทุกประการ"];
  List<String> userAnswers = [];
  int score = 0;

  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(questions.length, "");
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    setState(() {
      _message = 'กำลังส่งความคิดเห็น...';
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/add_comment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'comment_text': _commentController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        setState(() {
          _message = 'ความคิดเห็นถูกส่งสำเร็จ!';
        });
        _commentController.clear();
        _showQuizDialog();
      } else {
        setState(() {
          _message = 'ข้อผิดพลาดในการส่งความคิดเห็น: ${data['message']}';
        });
        _showQuizDialog();
      }
    } catch (e) {
      setState(() {
        _message = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
      _showQuizDialog();
    }
  }

  void _calculateAndSubmitScore(BuildContext dialogContext) async {
    score = 0;
    for (int i = 0; i < answers.length; i++) {
      if (userAnswers[i] == answers[i]) {
        score++;
      }
    }

    try {
      // ส่งคะแนนไป backend พร้อม route_id
      await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'route_id': widget.routeId, // ส่ง route_id
          'chapter_number': widget.chapter,
          'score': score,
        }),
      );

      // อัปเดตความคืบหน้าของบทเรียน (ไม่ไปบทต่อไปแล้ว แต่เป็นการจบเส้นทาง)
      // อาจจะเซ็ต current_chapter เป็น 1 และ current_route_id เป็น route_id ที่สำเร็จแล้ว + 1
      // เพื่อปลดล็อค route ถัดไป หรือนำไปหน้า Summary
      await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/update_progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'current_chapter': 1, // Reset ไปบทที่ 1
          'current_route_id': widget.routeId + 1, // ปลดล็อค route ถัดไป
        }),
      );
    } catch (e) {
      print('Error submitting score or updating progress: $e');
    }

    Navigator.pop(dialogContext); // ปิด AlertDialog ของแบบทดสอบ

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("คะแนนของคุณ"),
        content: Text("คุณทำคะแนนได้ $score จาก ${answers.length} คะแนน"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ปิด dialog คะแนน
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SummaryPage(username: widget.username),
                ),
              );
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showQuizDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('แบบทดสอบบทที่ ${widget.chapter}'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    for (int i = 0; i < questions.length; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questions[i],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...options[i].map((option) {
                            return RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue: userAnswers[i],
                              onChanged: (value) {
                                setDialogState(() {
                                  userAnswers[i] = value!;
                                });
                              },
                            );
                          }).toList(),
                          const SizedBox(height: 10),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _calculateAndSubmitScore(dialogContext);
                  },
                  child: const Text('ส่งคำตอบ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('บทที่ ${widget.chapter}')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/buddy_8.png',
                  height: 300,
                ),
                const SizedBox(height: 20),
                const Text(
                  "ฉันชื่อ ต้น เป็นนักเรียนมัธยมต้น อยู่ ม.2 ชอบเล่นกีฬา มีเพื่อนสนิทกลุ่มหนึ่งที่บางคนเริ่มสูบบุหรี่ไฟฟ้าเพราะดูเท่และกลิ่นหอม\n\n"
                  "วันหนึ่งหลังเลิกเรียน ต้นนั่งอยู่ใต้ตึกกับกลุ่มเพื่อนสนิท 3–4 คน เพื่อนคนหนึ่งหยิบบุหรี่ไฟฟ้าขึ้นมาแล้วบอกว่า\n\n"
                  "“ลองดูดิ กลิ่นมะม่วง หอมมาก ไม่อันตรายหรอก คนสูบกันเต็มเลย”\n\n"
                  "ต้นลังเล... เขาไม่เคยลองมาก่อน แต่ก็ไม่อยากโดนเพื่อนมองว่า “เชย” หรือ “กลัว”\n\n"
                  "เพื่อนยื่นบุหรี่ไฟฟ้ามาให้ต้น แล้วถามว่า: “จะลองไหม? ลองแค่ทีเดียวก็ได้”",
                  style: TextStyle(
                    fontSize: 20, // ปรับขนาดฟอนต์ให้เล็กลงหน่อย
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _commentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'คำแนะนำของคุณๆ คือ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "ส่งความคิดเห็น",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                _message.isNotEmpty
                    ? Text(
                        _message,
                        style: TextStyle(
                          color: _message.contains('ข้อผิดพลาด')
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
