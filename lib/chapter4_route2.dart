// lib/chapter4_route2.dart - บทที่ 4 สำหรับเส้นทางที่ 2
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'gate_result_page.dart';
import 'constants.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class Chapter4Route2Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId;
  final VoidCallback onFinished;

  Chapter4Route2Page({
    required this.chapter,
    required this.username,
    required this.routeId,
    required this.onFinished,
  });

  @override
  _Chapter4Route2PageState createState() => _Chapter4Route2PageState();
}

class _Chapter4Route2PageState extends State<Chapter4Route2Page> {
  // เนื้อหาสำหรับเส้นทางที่ 2 บทที่ 4 (แตกต่างจากเส้นทางที่ 1)
  List<String> questions = [
    "เมื่อมีคนชวนสูบบุหรี่ไฟฟ้าในงานปาร์ตี้ ควรตอบปฏิเสธอย่างไรให้สุภาพและมั่นคง?",
  ];
  List<List<String>> options = [
    [
      "บอกว่าไม่ชอบกลิ่น",
      "บอกว่าแพ้ควันบุหรี่ไฟฟ้า",
      "บอกว่ามีเหตุผลส่วนตัวที่ไม่สูบ",
      "บอกว่าไม่อยากลองเพราะสุขภาพสำคัญ",
    ],
  ];
  List<String> answers = ["บอกว่าไม่อยากลองเพราะสุขภาพสำคัญ"];
  late List<String> userAnswers; // Initialize userAnswers based on the number of questions

  int score = 0;
  int questionCount = 0; // Counter for chat messages to trigger quiz

  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  bool _isChatLoading = false;

  @override
  void initState() {
    super.initState();
    userAnswers = List<String>.filled(questions.length, "");
  }

  Future<void> _calculateAndSubmitScore() async {
    score = 0; // รีเซ็ตคะแนนสำหรับแบบทดสอบเฉพาะนี้
    for (int i = 0; i < answers.length; i++) {
      if (userAnswers[i] == answers[i]) {
        score++;
      }
    }

    // ตรวจสอบว่าแบบทดสอบในบทเรียนปัจจุบันเสร็จสมบูรณ์แล้วหรือไม่
    bool isCurrentChapterQuizFinished = true; // สำหรับบทนี้คือ True เสมอ เพราะเป็นแบบทดสอบข้อเดียวหลังแชท

    int chapterToAdvanceTo = widget.chapter;
    int routeIdToAdvanceTo = widget.routeId;

    if (isCurrentChapterQuizFinished) {
      // สมมติว่ามี 5 บทต่อหนึ่งเส้นทาง (บทที่ 1 ถึง 5)
      if (widget.chapter == 5) {
        // หากเป็นบทที่ 5 (บทสุดท้ายของเส้นทาง) ให้กลับไปบทที่ 1 และเลื่อนไปเส้นทางถัดไป
        chapterToAdvanceTo = 1; // กลับไปบทที่ 1 สำหรับเส้นทางถัดไป
        routeIdToAdvanceTo = widget.routeId + 1; // เลื่อนไปเส้นทางถัดไป
      } else {
        // หากไม่ใช่บทที่ 5 ให้เลื่อนไปบทถัดไปในเส้นทางเดิม
        chapterToAdvanceTo = widget.chapter + 1;
        routeIdToAdvanceTo = widget.routeId;
      }
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
          'is_finished': isCurrentChapterQuizFinished, // True เพราะแบบทดสอบเสร็จสิ้น
          'next_chapter': chapterToAdvanceTo, // บทที่ผู้ใช้ควรจะก้าวหน้าไป
          'next_route_id': routeIdToAdvanceTo, // เส้นทางที่ผู้ใช้ควรจะก้าวหน้าไป
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

    // หลังจากส่งคะแนน ให้นำทางไปยัง GateResultPage
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GateResultPage(
          username: widget.username,
          nextChapter: chapterToAdvanceTo,
          nextRouteId: routeIdToAdvanceTo,
          message: 'จบบทที่ ${widget.chapter} แล้ว 🎉', // ปรับข้อความ
          chapterDescription: 'กำลังเข้าสู่บทต่อไป...', // ปรับคำอธิบาย
        ),
      ),
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
        'http://localhost:5678/webhook/abc0daf3-a0e9-4e92-9f6e-9000a8980e69',
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
          questionCount++;
        });

        if (questionCount >= 3) {
          questionCount = 0;
          if (Navigator.canPop(context)) Navigator.pop(context);
          _showQuiz();
        }
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

  void _showQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                      Navigator.of(context).pop(); // ปิดกล่องแบบทดสอบ
                      await _calculateAndSubmitScore(); // คำนวณและส่งคะแนน
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
      appBar: AppBar(title: Text('เส้นทางที่ ${widget.routeId} - บทที่ ${widget.chapter}')),
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
              const Text("ในสถานการณ์ที่มีความกดดัน คุณจะตอบสนองต่อการชักชวนให้สูบบุหรี่ไฟฟ้าอย่างไร?"),
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
            ],
          ),
        ),
      ),
    );
  }
}