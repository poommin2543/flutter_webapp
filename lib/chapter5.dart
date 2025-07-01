// lib/chapter5.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'summary_page.dart'; // Import the new SummaryPage
import 'constants.dart'; // นำเข้า AppConstants
import 'dart:html' as html; // For AudioElement in Flutter Web

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
    "ถ้าคุณเป็นต้น คุณจะจัดการกับความเครียดของตัวเองอย่างไร โดยไม่พึ่งบุหรี่ไฟฟ้า?",
  ];

  final List<List<String>> options = [
    [
      "สูบตามเพื่อน เพื่อให้รู้สึกดีขึ้นเร็ว ๆ",
      "หาวิธีคลายเครียดที่ดีต่อสุขภาพ เช่น เดินเล่น ฟังเพลง หรือคุยกับคนที่ไว้ใจได้",
      "ไม่ทำอะไรเลย เก็บไว้คนเดียว",
      "บ่นให้เพื่อนฟังแล้วขอให้เขาเอามาให้สูบอีก",
    ],
  ];

  final List<String> answers = [
    "หาวิธีคลายเครียดที่ดีต่อสุขภาพ เช่น เดินเล่น ฟังเพลง หรือคุยกับคนที่ไว้ใจได้",
  ];
  late List<String>
  userAnswers; // Initialize userAnswers based on question length
  int score = 0;
  final html.AudioElement backgroundAudio =
      html.AudioElement('assets/sounds/background.mp3')
        ..loop = true
        ..autoplay = true
        ..volume = 0.3;

  @override
  void initState() {
    super.initState();
    backgroundAudio.play();
    userAnswers = List.filled(questions.length, "");
  }

  @override
  void dispose() {
    backgroundAudio.pause();
    backgroundAudio.src = '';
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
        _showQuizDialog(); // แสดงแบบทดสอบหลังจากส่งความคิดเห็นสำเร็จ
      } else {
        setState(() {
          _message = 'ข้อผิดพลาดในการส่งความคิดเห็น: ${data['message']}';
        });
        _showQuizDialog(); // แสดงแบบทดสอบแม้ว่าการส่งความคิดเห็นจะล้มเหลว (สำหรับตอนนี้)
      }
    } catch (e) {
      setState(() {
        _message = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
      _showQuizDialog(); // แสดงแบบทดสอบแม้ว่าจะเกิดข้อผิดพลาดในการเชื่อมต่อ
    }
  }

  void _calculateAndSubmitScore(BuildContext dialogContext) async {
    score = 0;
    for (int i = 0; i < answers.length; i++) {
      if (userAnswers[i] == answers[i]) {
        score++;
      }
    }

    // ตรวจสอบว่าแบบทดสอบในบทเรียนปัจจุบันเสร็จสมบูรณ์แล้วหรือไม่
    bool isCurrentChapterQuizFinished =
        true; // สำหรับบทนี้คือ True เสมอ เพราะเป็นแบบทดสอบข้อเดียวหลังแชท

    int chapterToAdvanceTo = widget.chapter;
    int routeIdToAdvanceTo = widget.routeId;

    if (isCurrentChapterQuizFinished) {
      // เนื่องจากเป็นบทที่ 5 จึงเป็นบทสุดท้ายของเส้นทาง
      // สมมติว่ามี 5 บทต่อหนึ่งเส้นทาง (บทที่ 1 ถึง 5)
      // หากมีเส้นทางเพิ่มเติม คุณจะต้องเลื่อน routeId
      // ตอนนี้ หาก widget.routeId มีค่าสูงสุด (เช่น 3) คุณอาจจะไปที่หน้าสรุปผลสุดท้าย
      // ที่นี่ เราจะถือว่าเป็นการจบบทเรียนหนึ่งเส้นทาง ดังนั้นบทถัดไปคือ 1 และเส้นทางถัดไปคือ widget.routeId + 1
      chapterToAdvanceTo = 1; // กลับไปบทที่ 1 สำหรับเส้นทางถัดไป
      routeIdToAdvanceTo = widget.routeId + 1; // เลื่อนไปเส้นทางถัดไป
    }

    // ส่งคะแนนและสถานะความคืบหน้าไปยัง Backend
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'chapter': widget.chapter, // บทที่เพิ่งทำแบบทดสอบเสร็จ
          'score': score, // คะแนนที่ได้จากแบบทดสอบนี้
          'route_id': widget.routeId,
          'is_finished':
              isCurrentChapterQuizFinished, // True เพราะแบบทดสอบเสร็จสิ้น
          'next_chapter': chapterToAdvanceTo, // บทที่ผู้ใช้ควรจะก้าวหน้าไป
          'next_route_id':
              routeIdToAdvanceTo, // เส้นทางที่ผู้ใช้ควรจะก้าวหน้าไป
        }),
      );

      if (response.statusCode == 200) {
        print('Score submitted successfully! Progress updated on Backend.');
      } else {
        print(
          'Failed to submit score: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error submitting score: $e');
    }

    // ปิดกล่องแบบทดสอบ
    Navigator.pop(dialogContext);

    // หลังจากส่งคะแนน ให้นำทางไปยัง SummaryPage
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
              title: Text(
                'แบบทดสอบบทที่ ${widget.chapter} เส้นทางที่ ${widget.routeId}',
              ),
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
                    // ตรวจสอบว่ามีการเลือกคำตอบสำหรับแบบทดสอบแล้ว
                    if (userAnswers.every((answer) => answer.isNotEmpty)) {
                      _calculateAndSubmitScore(dialogContext);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณาเลือกคำตอบก่อนส่ง')),
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
      appBar: AppBar(
        title: Text('บทที่ ${widget.chapter} ทักษะการจัดการตนเอง'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/buddy_8g.gif', height: 300),
                const SizedBox(height: 20),
                const Text(
                  "เมื่อฉันรู้สึกเครียด และมีคนเสนอให้สูบบุหรี่ไฟฟ้าเพื่อคลายความเครียด...",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const Text(
                  "หลังจากสอบกลางภาค ต้นรู้สึกเครียดมาก เพราะทำข้อสอบบางวิชาไม่ได้เลย ขณะนั่งพักอยู่หลังโรงเรียน เพื่อนคนหนึ่งเดินเข้ามาแล้วพูดว่า <สูบอันนี้ดูสิ มันช่วยให้ผ่อนคลายนะ เราสูบแล้วรู้สึกดีขึ้นเยอะเลย> ต้นลังเล เขารู้ว่าบุหรี่ไฟฟ้าไม่ดีต่อสุขภาพ แต่ในใจก็เครียดจนไม่รู้จะทำยังไงดี",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Text(
                  questions[0], // Dynamically show your defined question
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...options[0].map(
                  (option) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: double.infinity,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: RadioListTile<String>(
                        title: Text(option, textAlign: TextAlign.center),
                        value: option,
                        groupValue: userAnswers[0],
                        onChanged: (val) {
                          setState(() {
                            userAnswers[0] = val!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: userAnswers[0].isNotEmpty
                      ? () {
                          _calculateAndSubmitScore(context);
                        }
                      : null,
                  child: const Text("ส่งคำตอบ"),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
