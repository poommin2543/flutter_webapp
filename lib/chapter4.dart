// lib/chapter4.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่รวม
import 'constants.dart'; // นำเข้า AppConstants

// คลาสสำหรับเก็บข้อมูลข้อความแชท
class ChatMessage {
  final String text;
  final bool isUser; // true ถ้าเป็นข้อความจากผู้ใช้, false ถ้าเป็นจาก bot

  ChatMessage({required this.text, required this.isUser});
}

// วิดเจ็ตหลักสำหรับ Chapter 4
class Chapter4Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId; // เพิ่ม: รับ routeId เข้ามา
  final VoidCallback onFinished; // Callback เมื่อจบ Chapter

  Chapter4Page({
    required this.chapter,
    required this.username,
    required this.routeId, // กำหนดให้รับ routeId
    required this.onFinished,
  });

  @override
  _Chapter4PageState createState() => _Chapter4PageState();
}

class _Chapter4PageState extends State<Chapter4Page> {
  // ข้อมูลแบบทดสอบ (Quiz) ที่กำหนดไว้ล่วงหน้า
  List<String> questions = [
    "ลองสูบบุหรี่ไฟฟ้าหน่อยไหม มันหอมและอร่อยมากเลยนะ ไม่อันตรายด้วย",
  ];
  List<List<String>> options = [
    [
      "จริงเหรอ มันจะไม่ติดใช่ไหม",
      "ยังไงฉันก็จะไม่ยุ่งกับมันเด็ดขาด",
      "ขอลองสักหน่อยคงไม่เสียหาย",
      "เห็นคนอื่นสูบก็ดูเท่ห์นะ ลองละกัน",
    ],
  ];
  List<String> answers = ["ยังไงฉันก็จะไม่ยุ่งกับมันเด็ดขาด"];
  List<String> userAnswers = [];

  int score = 0; // คะแนนของผู้ใช้
  // int questionCount = 0; // ตัวแปรสำหรับนับจำนวนครั้งที่ AI ตอบกลับ - ไม่จำเป็นต้องใช้สำหรับปุ่มทดสอบ

  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  bool _isChatLoading = false;

  @override
  void initState() {
    super.initState();
    userAnswers = List<String>.filled(questions.length, "");
  }

  // ฟังก์ชันสำหรับคำนวณคะแนนแบบทดสอบและแสดงผล
  Future<void> calculateAndSubmitScore() async {
    score = 0;
    for (int i = 0; i < answers.length; i++) {
      if (userAnswers[i] == answers[i]) {
        score++;
      }
    }

    print('Chapter ${widget.chapter} (Route ${widget.routeId}) finished. Final score: $score');

    // กำหนดค่าสำหรับส่งไป Backend
    bool isFinishedChapter = (widget.chapter == 5); // ถ้าเป็นบทที่ 5 คือจบบทเรียนในเส้นทางนั้น
    int nextChapterToSend = widget.chapter + 1; // บทถัดไป (อาจเป็น 6 ถ้าจบบท 5)
    int nextRouteIDToSend = widget.routeId;     // เส้นทางยังคงเดิม

    // ถ้าจบบทที่ 5 แล้ว (isFinishedChapter = true)
    // ให้ nextChapterToSend เป็น 6 และ nextRouteIDToSend เป็น 1
    if (isFinishedChapter) {
      nextChapterToSend = 6;
      nextRouteIDToSend = 1;
    }

    // ส่งคะแนนไป backend พร้อม route_id และข้อมูลความคืบหน้า
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'chapter': widget.chapter,
          'score': score,
          'route_id': widget.routeId, // ส่ง route_id
          'is_finished': isFinishedChapter,
          'next_chapter': nextChapterToSend,
          'next_route_id': nextRouteIDToSend,
        }),
      );
      if (response.statusCode == 200) {
        print('Score submitted successfully! Progress updated on Backend.');
      } else {
        print('Failed to submit score: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error submitting score: $e');
    }

    // ปิด dialog แบบทดสอบก่อน
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("คะแนนของคุณ"),
          content: Text(
            "คุณได้ $score จาก ${answers.length} คะแนน",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ปิด dialog แสดงผลคะแนน
                // นำทางไปยัง GateResultPage ที่รวมไว้
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GateResultPage(
                      chapterDescription: 'บททดสอบเกี่ยวกับการจัดการตนเอง', // ควรปรับให้เหมาะสม
                      message: 'จบบทที่ ${widget.chapter} แล้ว 🎉',
                      nextChapter: nextChapterToSend,
                      nextRouteId: nextRouteIDToSend,
                      username: widget.username,
                    ),
                  ),
                );
              },
              child: const Text("ตกลง"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMessageToN8n(StateSetter setModalState) async {
    final userMessage = _chatController.text;
    if (userMessage.isEmpty) return;

    setModalState(() {
      _chatMessages.add(ChatMessage(text: userMessage, isUser: true));
      _isChatLoading = true;
    });
    _chatController.clear();

    try {
      final url = Uri.parse(
        'http://localhost:5678/webhook/abc0daf3-a0e9-4e92-9f6e-9000a8980e69', // ตรวจสอบ URL นี้
        // 'https://n8nmoss.roverautonomous.com/webhook/1054bc91-ee04-46fd-94a8-4b2055e6087f',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': widget.username, 'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final botReply = responseBody['reply'] ?? 'ขออภัย ฉันไม่เข้าใจ.';

        setModalState(() {
          _chatMessages.add(ChatMessage(text: botReply, isUser: false));
          // questionCount++; // ไม่จำเป็นต้องใช้แล้วถ้าใช้ปุ่มเริ่มทดสอบโดยตรง
        });

        // if (questionCount >= 3) { // ไม่จำเป็นต้องใช้แล้วถ้าใช้ปุ่มเริ่มทดสอบโดยตรง
        //   questionCount = 0; // รีเซ็ต
        //   _showQuiz();
        // }
      } else {
        setModalState(() {
          _chatMessages.add(
            ChatMessage(text: 'ข้อผิดพลาด: ${response.statusCode}', isUser: false),
          );
        });
      }
    } catch (e) {
      setModalState(() {
        _chatMessages.add(
          ChatMessage(text: 'ข้อผิดพลาดการเชื่อมต่อ: ${e.toString()}', isUser: false),
        );
      });
    } finally {
      setModalState(() {
        _isChatLoading = false;
      });
    }
  }

  // ฟังก์ชันสำหรับแสดงแบบทดสอบ (Quiz)
  void _showQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด dialog ด้วยการแตะนอกกรอบ
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: const Text("แบบทดสอบ!"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < questions.length; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(questions[i], style: const TextStyle(fontSize: 18)),
                          ...options[i].map((option) {
                            return RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue: userAnswers[i],
                              onChanged: (value) {
                                setModalState(() {
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
                  onPressed: () async {
                    if (userAnswers.every((answer) => answer.isNotEmpty)) {
                      await calculateAndSubmitScore(); // เรียกฟังก์ชันนี้
                      // การปิด dialog หลังจากนี้จะถูกจัดการใน calculateAndSubmitScore
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'กรุณาเลือกคำตอบก่อนส่ง',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("ส่ง"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ฟังก์ชันสำหรับแสดงหน้าต่างแชท (Bottom Sheet)
  void _showChatDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, index) {
                          final message = _chatMessages.reversed.toList()[index];
                          return Align(
                            alignment: message.isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: message.isUser
                                    ? Colors.blue[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: message.isUser
                                  ? Text(message.text)
                                  : MarkdownBody(
                                      data: message.text,
                                      shrinkWrap: true,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_isChatLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: InputDecoration(
                                hintText: 'ถามอะไรสักอย่าง...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onSubmitted: (_) => _sendMessageToN8n(
                                setModalState,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () => _sendMessageToN8n(
                              setModalState,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showChatDialog,
        child: const Icon(Icons.chat_bubble_outline),
        tooltip: 'Chat with AI Assistant',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text("ถ้าคุณถูกชักชวนให้สูบบุหรี่ไฟฟ้า "),
              Image.asset(
                'assets/images/buddy_8.png',
                height: 400,
              ),
              const SizedBox(height: 10),
              const Text(
                "คุณจะทำอย่างไร",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                "สวัสดี! ฉันพร้อมจะช่วยให้คำปรึกษาแล้วนะ เปิดกล่องข้อความด้างล่างเพื่อคุยกับฉันเลย",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _showQuiz, // ปุ่มสำหรับเริ่มบททดสอบ
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('เริ่มบททดสอบ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
