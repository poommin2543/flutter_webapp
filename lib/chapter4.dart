import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่รวม
import 'constants.dart'; // นำเข้า AppConstants
import 'dart:html' as html; // For AudioElement in Flutter Web

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
      "ยังไงฉันก็จะไม่ยุ่งเกี่ยวกับบุหรี่ไฟฟ้าเด็ดขาด เพราะมันอันตรายต่อสุขภาพและอนาคตของฉัน",
      "ขอลองแค่ครั้งเดียว",
      "ไม่เป็นไร ขอบคุณ",
    ],
  ];
  List<String> answers = [
    "ยังไงฉันก็จะไม่ยุ่งเกี่ยวกับบุหรี่ไฟฟ้าเด็ดขาด เพราะมันอันตรายต่อสุขภาพและอนาคตของฉัน",
  ];
  late List<String>
  userAnswers; // Initialize userAnswers based on the number of questions

  int score = 0; // Score for the quiz in this chapter
  int questionCount = 0; // Counter for chat messages to trigger quiz

  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  bool _isChatLoading = false;
  final html.AudioElement backgroundAudio =
      html.AudioElement('assets/sounds/background.mp3')
        ..loop = true
        ..autoplay = true
        ..volume = 0.3;

  @override
  void initState() {
    super.initState();
    backgroundAudio.play();
    userAnswers = List<String>.filled(
      questions.length,
      "",
    ); // Initialize userAnswers correctly
  }

  @override
  void dispose() {
    backgroundAudio.pause();
    backgroundAudio.src = '';
    super.dispose();
  }

  Future<void> _calculateAndSubmitScore() async {
    score = 0; // Reset score for this specific quiz
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
        // 'http://localhost:5678/webhook/abc0daf3-a0e9-4e92-9f6e-9000a8980e69',
        'https://n8nmoss.roverautonomous.com/webhook/1054bc91-ee04-46fd-94a8-4b2055e6087f',
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

        // กระตุ้นแบบทดสอบหลังจากแชทครบ 3 รอบ (หรือตามที่กำหนด)
        if (questionCount >= 3) {
          questionCount = 0; // รีเซ็ตตัวนับ
          // ปิดกล่องแชทก่อนแสดงแบบทดสอบ
          if (Navigator.canPop(context)) Navigator.pop(context);
          _showQuiz(); // แสดงแบบทดสอบ
        }
      } else {
        setModalState(() {
          _chatMessages.add(
            ChatMessage(
              text: 'ข้อผิดพลาด: ${response.statusCode}',
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      setModalState(() {
        _chatMessages.add(
          ChatMessage(
            text: 'ข้อผิดพลาดการเชื่อมต่อ: ${e.toString()}',
            isUser: false,
          ),
        );
      });
    } finally {
      setModalState(() {
        _isChatLoading = false;
      });
    }
  }

  Widget _buildQuiz() {
    return Column(
      children: [
        Text(
          questions[0],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        ...options[0].map((opt) {
          bool enabled = userAnswers[0].isEmpty; // not submitted yet
          return Card(
            elevation: 3,
            child: RadioListTile<String>(
              title: Text(opt, textAlign: TextAlign.center),
              value: opt,
              groupValue: userAnswers[0],
              onChanged: enabled
                  ? (val) {
                      setState(() => userAnswers[0] = val!);
                    }
                  : null,
            ),
          );
        }).toList(),
        ElevatedButton(
          onPressed: userAnswers[0].isNotEmpty
              ? _calculateAndSubmitScore
              : null,
          child: const Text('ส่งคำตอบ'),
        ),
      ],
    );
  }

  void _showQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String selected = '';
        return StatefulBuilder(
          builder: (ctx, modalSetState) {
            return AlertDialog(
              title: Text("แบบทดสอบการตัดสินใจ"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(questions[0], style: TextStyle(fontSize: 30)),
                  ...options[0].map(
                    (opt) => Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: RadioListTile<String>(
                        title: Text(opt, textAlign: TextAlign.center),
                        value: opt,
                        groupValue: selected,
                        onChanged: (val) =>
                            modalSetState(() => selected = val!),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("ส่ง"),
                  onPressed: selected.isEmpty
                      ? null
                      : () {
                          userAnswers[0] = selected;
                          Navigator.of(ctx).pop();
                          _calculateAndSubmitScore();
                        },
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
      backgroundColor: Colors.white,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // Start at 60% height
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          reverse: true,
                          itemCount: _chatMessages.length,
                          itemBuilder: (context, index) {
                            final message = _chatMessages.reversed
                                .toList()[index];
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
                                  hintText: 'มีอะไรพูดคุยกับฉันเลย',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onSubmitted: (_) =>
                                    _sendMessageToN8n(setModalState),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () => _sendMessageToN8n(setModalState),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool quizEnabled = questionCount >= 3;

    return Scaffold(
      appBar: AppBar(
        title: Text('บทที่ ${widget.chapter} ทักษะการตัดสินใจ'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Main content (scrollable column)
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "ถ้าคุณถูกชักชวนให้สูบบุหรี่ไฟฟ้า คุณจะทำอย่างไร",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  Image.asset('assets/images/buddy_8g.gif', height: 400),
                  const SizedBox(height: 100),
                  const Text(
                    "สวัสดี! ฉันพร้อมจะช่วยให้คำปรึกษาแล้วนะ เปิดกล่องข้อความด้างล่างเพื่อคุยกับฉันเลย (ถามฉันสัก 3 คำถามแล้วฉันจะถามคำถามกลับให้คุณตัดสินใจ)",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  if (quizEnabled) _buildQuiz(),
                ],
              ),
            ),
          ),
          // Positioned chat button near the image
          Align(
            alignment: Alignment(0.7, -0.3), // x: 0 is center; tweak as needed
            child: RawMaterialButton(
              onPressed: _showChatDialog,
              elevation: 2.0,
              fillColor: Colors.blue,
              shape: const CircleBorder(),
              constraints: const BoxConstraints.tightFor(
                width: 200, // ⬅️ Increase button width
                height: 200, // ⬅️ Increase button height
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 120, // ⬅️ Large icon
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
