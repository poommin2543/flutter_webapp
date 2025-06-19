import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart'; // เพิ่ม import นี้

// ✅ 1. สร้าง Class สำหรับจัดเก็บข้อมูลข้อความแชท
class ChatMessage {
  final String text;
  final bool isUser; // true ถ้าเป็นข้อความจากผู้ใช้, false ถ้าเป็นจาก n8n/bot

  ChatMessage({required this.text, required this.isUser});
}

class Chapter3Page extends StatefulWidget {
  final int chapter;
  final String username;
  final VoidCallback onFinished;

  Chapter3Page({
    required this.chapter,
    required this.username,
    required this.onFinished,
  });

  @override
  _Chapter3PageState createState() => _Chapter3PageState();
}

class _Chapter3PageState extends State<Chapter3Page> {
  // --- ส่วนของ Quiz (โค้ดเดิม) ---
  List<String> questions = [
    "What is the capital of France?",
    "What is 2 + 2?",
    "Who is the CEO of Tesla?",
  ];
  List<List<String>> options = [
    ["Paris", "London", "Berlin", "Rome"],
    ["3", "4", "5", "6"],
    ["Elon Musk", "Jeff Bezos", "Bill Gates", "Mark Zuckerberg"],
  ];
  List<String> answers = ["Paris", "4", "Elon Musk"];
  List<String> userAnswers = ["", "", ""];
  int score = 0;

  // ✅ 2. เพิ่ม State Variables สำหรับแชท
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  bool _isChatLoading = false;


  // --- ฟังก์ชันของ Quiz (โค้ดเดิม) ---
  void calculateScore() async {
    // ... โค้ดส่วนนี้เหมือนเดิม ...
    // ตัวอย่างการคำนวณคะแนนง่ายๆ (หากยังไม่มี)
    score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == answers[i]) {
        score++;
      }
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Quiz Result"),
          content: Text("You scored $score out of ${questions.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally, call onFinished if quiz is done
                // widget.onFinished();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ✅ 3. ปรับเปลี่ยนฟังก์ชัน _sendMessageToN8n ให้รับ StateSetter
  //    เพื่อให้สามารถอัปเดต UI ของ dialog ได้โดยตรง
  Future<void> _sendMessageToN8n(StateSetter setModalState) async {
    final userMessage = _chatController.text;
    if (userMessage.isEmpty) return;

    setModalState(() {
      _chatMessages.add(ChatMessage(text: userMessage, isUser: true));
      _isChatLoading = true;
    });
    _chatController.clear();

    try {
      // 🚀 **สำคัญ:** แก้ไข URL นี้เป็น n8n Webhook URL ของคุณ
      final url = Uri.parse('https://n8nmoss.roverautonomous.com/webhook/1054bc91-ee04-46fd-94a8-4b2055e6087f');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'message': userMessage,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // สมมติว่า n8n ตอบกลับมาเป็น JSON ที่มี key ชื่อ 'reply'
        final botReply = responseBody['reply'] ?? 'Sorry, I did not get that.';
        
        setModalState(() {
          _chatMessages.add(ChatMessage(text: botReply, isUser: false));
        });

      } else {
         setModalState(() {
          _chatMessages.add(ChatMessage(text: 'Error: ${response.statusCode}', isUser: false));
        });
      }
    } catch (e) {
      setModalState(() {
        _chatMessages.add(ChatMessage(text: 'Error: ${e.toString()}', isUser: false));
      });
    } finally {
      setModalState(() {
        _isChatLoading = false;
      });
    }
  }

  // ✅ 4. เพิ่มฟังก์ชันสำหรับแสดงหน้าต่างแชท (Bottom Sheet)
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
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    // ส่วนแสดงผลข้อความ
                    Expanded(
                      child: ListView.builder(
                        reverse: true, // แสดงข้อความล่าสุดข้างล่าง
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, index) {
                          final message = _chatMessages.reversed.toList()[index];
                          return Align(
                            alignment: message.isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: message.isUser ? Colors.blue[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // *** ใช้ MarkdownBody สำหรับข้อความจาก AI ***
                              child: message.isUser
                                  ? Text(message.text)
                                  : MarkdownBody(
                                      data: message.text,
                                      shrinkWrap: true,
                                      // Optional: กำหนด style เพิ่มเติม
                                      styleSheet: MarkdownStyleSheet(
                                        codeblockDecoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        code: TextStyle(
                                          fontFamily: 'monospace', // ใช้ font ที่เป็น monospace สำหรับโค้ด
                                          backgroundColor: Colors.grey[300],
                                          color: Colors.black87,
                                        ),
                                        // เพิ่ม style อื่นๆ ตามต้องการ เช่น headers, bold, italic
                                        // p: TextStyle(fontSize: 14),
                                        // strong: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_isChatLoading)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    // ส่วนพิมพ์ข้อความ
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: InputDecoration(
                                hintText: 'Ask something...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              // 🎯 เรียก _sendMessageToN8n พร้อมส่ง setModalState
                              onSubmitted: (_) => _sendMessageToN8n(setModalState),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            // 🎯 เรียก _sendMessageToN8n พร้อมส่ง setModalState
                            onPressed: () => _sendMessageToN8n(setModalState),
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
      appBar: AppBar(title: Text('Chapter ${widget.chapter}')),
      // ✅ 5. เพิ่ม FloatingActionButton เพื่อเปิดแชท
      floatingActionButton: FloatingActionButton(
        onPressed: _showChatDialog,
        child: Icon(Icons.chat_bubble_outline),
        tooltip: 'Chat with AI Assistant',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // ใช้ SingleChildScrollView เพื่อกันหน้าจอล้น
          child: Column(
            children: [
              // --- โค้ดส่วน Quiz เหมือนเดิม ---
              for (int i = 0; i < questions.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(questions[i], style: TextStyle(fontSize: 18)),
                    ...options[i].map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: userAnswers[i],
                        onChanged: (value) {
                          setState(() {
                            userAnswers[i] = value!;
                          });
                        },
                      );
                    }).toList(),
                    SizedBox(height: 10),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: calculateScore, child: Text("Submit")),
              SizedBox(height: 80), // เพิ่มพื้นที่ว่างด้านล่างกันปุ่ม FAB บัง
            ],
          ),
        ),
      ),
    );
  }
}