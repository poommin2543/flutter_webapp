import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'summary_page.dart'; // Import the new SummaryPage

class Chapter5Page extends StatefulWidget {
  final int chapter;
  final String username;
  final VoidCallback onFinished;

  Chapter5Page({
    required this.chapter,
    required this.username,
    required this.onFinished,
  });

  @override
  _Chapter5PageState createState() => _Chapter5PageState();
}

class _Chapter5PageState extends State<Chapter5Page> {
  // Controller สำหรับช่องกรอกความคิดเห็น
  final TextEditingController _commentController = TextEditingController();
  String _message = ''; // สำหรับแสดงข้อความสถานะ (เช่น ส่งสำเร็จ, ข้อผิดพลาด)

  // ข้อมูลสำหรับคำถาม (ยังคงอยู่เพื่อใช้ใน AlertDialog)
  final List<String> questions = [
    "การแนะนำเพื่อนที่ดีด้วยใจของเราเอง เป็นสิ่งที่มีคุณค่า?",
  ];

  final List<List<String>> options = [
    ["ใช่ ทุกประการ", "ใช่ บางประการ", "ไม่ใช่ บางประการ", "ไม่ใช่ทุกประการ"],
  ];

  final List<String> answers = ["ใช่ ทุกประการ"];
  List<String> userAnswers = []; // Initialized in initState
  int score = 0;

  @override
  void initState() {
    super.initState();
    // Initialize userAnswers with empty strings based on the number of questions
    userAnswers = List.filled(questions.length, "");
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับส่งความคิดเห็นไปยัง Backend
  Future<void> _submitComment() async {
    setState(() {
      _message = 'กำลังส่งความคิดเห็น...';
    });

    try {
      final response = await http.post(
        // ใช้ URL ของ Go backend ที่รันอยู่
        Uri.parse(
          'https://apiwebmoss.roverautonomous.com/add_comment',
        ), // <-- อัปเดต URL นี้
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
        _commentController.clear(); // ล้างช่องกรอกข้อความ
        _showQuizDialog(); // แสดงแบบทดสอบหลังจากส่งความคิดเห็น
      } else {
        setState(() {
          _message = 'ข้อผิดพลาดในการส่งความคิดเห็น: ${data['message']}';
        });
        _showQuizDialog(); // แสดงแบบทดสอบแม้จะส่งความคิดเห็นไม่สำเร็จ
      }
    } catch (e) {
      setState(() {
        _message = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
      _showQuizDialog(); // แสดงแบบทดสอบในกรณีเกิดข้อผิดพลาดในการเชื่อมต่อ
    }
  }

  // ฟังก์ชันสำหรับคำนวณคะแนนและส่งไปยัง Backend (ใช้ใน AlertDialog)
  void _calculateAndSubmitScore(BuildContext dialogContext) async {
    score = 0;
    for (int i = 0; i < answers.length; i++) {
      if (userAnswers[i] == answers[i]) {
        score++;
      }
    }

    try {
      // ส่งคะแนนไป backend
      await http.post(
        Uri.parse('https://apiwebmoss.roverautonomous.com/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'chapter_number': widget.chapter,
          'score': score,
        }),
      );

      // อัปเดตความคืบหน้าของบทเรียน
      await http.post(
        Uri.parse('https://apiwebmoss.roverautonomous.com/update_progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'current_chapter': widget.chapter + 1,
        }),
      );
    } catch (e) {
      print('Error submitting score or updating progress: $e');
      // อาจเพิ่มการแจ้งเตือนผู้ใช้ว่ามีข้อผิดพลาดในการส่งคะแนน
    }

    // ปิด AlertDialog ของแบบทดสอบก่อนแสดง AlertDialog คะแนน
    Navigator.pop(dialogContext);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("คะแนนของคุณ"),
        content: Text("คุณทำคะแนนได้ $score จาก ${answers.length} คะแนน"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ปิด dialog คะแนน
              // แทนที่ widget.onFinished() ด้วยการนำทางไปยัง SummaryPage
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

  // ฟังก์ชันสำหรับแสดงแบบทดสอบในรูปแบบ AlertDialog
  void _showQuizDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด dialog ด้วยการแตะที่อื่น
      builder: (BuildContext dialogContext) {
        // ใช้ StatefulBuilder เพื่อจัดการ State ของ RadioListTile ภายใน AlertDialog
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('แบบทดสอบบทที่ ${widget.chapter}'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // จำกัดขนาด Column ให้พอดีกับเนื้อหา
                  children: [
                    // ลบ Image.asset ออกไป
                    SizedBox(height: 20),
                    for (int i = 0; i < questions.length; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questions[i],
                            style: TextStyle(
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
                                  // ใช้ setDialogState เพื่ออัปเดต UI ภายใน dialog
                                  userAnswers[i] = value!;
                                });
                              },
                            );
                          }).toList(),
                          SizedBox(height: 10),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _calculateAndSubmitScore(
                      dialogContext,
                    ); // ส่ง dialogContext ไปด้วย
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
                // ลบ Image.asset ออกไป
                const SizedBox(height: 20),
                // 🧍‍♂️ INSERT CHARACTER IMAGE HERE
                Image.asset(
                  'assets/images/buddy_8.png', // Replace with your actual path
                  height: 300,
                ),

                const SizedBox(height: 20),

                // ข้อความ "อะไรก็ได้"
                const Text(
                  "ฉันชื่อ ต้น เป็นนักเรียนมัธยมต้น อยู่ ม.2 ชอบเล่นกีฬา มีเพื่อนสนิทกลุ่มหนึ่งที่บางคนเริ่มสูบบุหรี่ไฟฟ้าเพราะดูเท่และกลิ่นหอม\n\n"
                  "วันหนึ่งหลังเลิกเรียน ต้นนั่งอยู่ใต้ตึกกับกลุ่มเพื่อนสนิท 3–4 คน เพื่อนคนหนึ่งหยิบบุหรี่ไฟฟ้าขึ้นมาแล้วบอกว่า\n\n"
                  "“ลองดูดิ กลิ่นมะม่วง หอมมาก ไม่อันตรายหรอก คนสูบกันเต็มเลย”\n\n"
                  "ต้นลังเล... เขาไม่เคยลองมาก่อน แต่ก็ไม่อยากโดนเพื่อนมองว่า “เชย” หรือ “กลัว”\n\n"
                  "เพื่อนยื่นบุหรี่ไฟฟ้ามาให้ต้น แล้วถามว่า: “จะลองไหม? ลองแค่ทีเดียวก็ได้”",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // ช่องกรอกความคิดเห็น
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

                // ปุ่มส่งความคิดเห็น
                ElevatedButton(
                  onPressed: _submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // สีพื้นหลัง
                    foregroundColor: Colors.white, // สีตัวอักษร
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

                // แสดงข้อความสถานะ
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
