// lib/chapter5_route2.dart - บทที่ 5 สำหรับเส้นทางที่ 2
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'summary_page.dart';
import 'constants.dart';

class Chapter5Route2Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId;
  final VoidCallback onFinished;

  Chapter5Route2Page({
    required this.chapter,
    required this.username,
    required this.routeId,
    required this.onFinished,
  });

  @override
  _Chapter5Route2PageState createState() => _Chapter5Route2PageState();
}

class _Chapter5Route2PageState extends State<Chapter5Route2Page> {
  final TextEditingController _commentController = TextEditingController();
  String _message = '';

  // เนื้อหาสำหรับเส้นทางที่ 2 บทที่ 5 (แตกต่างจากเส้นทางที่ 1)
  final List<String> questions = [
    "ในเส้นทางที่ 2 นี้ คุณได้เรียนรู้อะไรสำคัญที่สุดเกี่ยวกับการจัดการตนเอง?",
  ];

  final List<List<String>> options = [
    ["การปฏิเสธอย่างมั่นคง", "การหาข้อมูลที่ถูกต้อง", "การสร้างความสัมพันธ์ที่ดีกับเพื่อน", "การไม่ตัดสินผู้อื่น"],
  ];

  final List<String> answers = ["การปฏิเสธอย่างมั่นคง"];
  late List<String> userAnswers; // Initialize userAnswers based on question length
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

    if (_commentController.text.trim().isEmpty) {
      setState(() {
        _message = 'กรุณาพิมพ์ความคิดเห็นก่อนส่ง';
      });
      return;
    }

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

    bool isCurrentChapterQuizFinished = true; // สำหรับบทนี้คือ True เสมอ
    int chapterToAdvanceTo = widget.chapter;
    int routeIdToAdvanceTo = widget.routeId;

    if (isCurrentChapterQuizFinished) {
      // เนื่องจากเป็นบทที่ 5 จึงเป็นบทสุดท้ายของเส้นทาง
      chapterToAdvanceTo = 1; // กลับไปบทที่ 1 สำหรับเส้นทางถัดไป
      routeIdToAdvanceTo = widget.routeId + 1; // เลื่อนไปเส้นทางถัดไป
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'chapter': widget.chapter,
          'score': score,
          'route_id': widget.routeId,
          'is_finished': isCurrentChapterQuizFinished,
          'next_chapter': chapterToAdvanceTo,
          'next_route_id': routeIdToAdvanceTo,
        }),
      );

      if (response.statusCode == 200) {
        print('Score submitted successfully! Progress updated on Backend.');
      } else {
        print('Failed to submit score: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error submitting score or updating progress: $e');
    }

    Navigator.pop(dialogContext);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("คะแนนของคุณ"),
        content: Text("คุณทำคะแนนได้ $score จาก ${answers.length} คะแนน"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SummaryPage(username: widget.username)),
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
              title: Text('แบบทดสอบบทที่ ${widget.chapter} เส้นทางที่ ${widget.routeId}'),
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
                    if (userAnswers.every((answer) => answer.isNotEmpty)) {
                      _calculateAndSubmitScore(dialogContext);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('กรุณาเลือกคำตอบก่อนส่ง'),
                        ),
                      );
                    }
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
      appBar: AppBar(title: Text('เส้นทางที่ ${widget.routeId} - บทที่ ${widget.chapter}')),
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
                  "ในเส้นทางที่ 2 นี้ คุณได้เรียนรู้เกี่ยวกับทักษะการปฏิเสธและการจัดการตนเองเมื่อเผชิญกับการชักชวนให้สูบบุหรี่ไฟฟ้า",
                  style: TextStyle(
                    fontSize: 20,
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
                    hintText: 'คุณเรียนรู้อะไรจากการเดินทางในเส้นทางที่ 2 นี้บ้าง?',
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