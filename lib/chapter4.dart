import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'gate_result_page4.dart'; // นำเข้า GateResultPage ที่ถูกต้อง

// คลาสสำหรับเก็บข้อมูลข้อความแชท
class ChatMessage {
  final String text;
  final bool isUser; // true ถ้าเป็นข้อความจากผู้ใช้, false ถ้าเป็นจาก bot

  ChatMessage({required this.text, required this.isUser});
}

// วิดเจ็ตหลักสำหรับ Chapter 3
class Chapter4Page extends StatefulWidget {
  final int chapter;
  final String username;
  final VoidCallback onFinished; // Callback เมื่อจบ Chapter

  Chapter4Page({
    required this.chapter,
    required this.username,
    required this.onFinished,
  });

  @override
  _Chapter4PageState createState() => _Chapter4PageState();
}

class _Chapter4PageState extends State<Chapter4Page> {
  // ข้อมูลแบบทดสอบ (Quiz) ที่กำหนดไว้ล่วงหน้า
  // ในแอปพลิเคชันจริง อาจจะดึงมาจาก API หรือกำหนดค่าในที่อื่น
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
  // รายการสำหรับเก็บคำตอบของผู้ใช้สำหรับแต่ละคำถาม
  List<String> userAnswers = [];

  int score = 0; // คะแนนของผู้ใช้
  int questionCount = 0; // ตัวแปรสำหรับนับจำนวนครั้งที่ AI ตอบกลับ

  final TextEditingController _chatController =
      TextEditingController(); // ตัวควบคุมสำหรับช่องพิมพ์แชท
  final List<ChatMessage> _chatMessages = []; // รายการข้อความในแชท
  bool _isChatLoading = false; // สถานะการโหลดข้อความจาก n8n

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นของ userAnswers ให้มีขนาดเท่ากับจำนวนคำถาม
    // และใส่ค่าว่างเปล่า ("") ลงไปในแต่ละตำแหน่ง
    userAnswers = List<String>.filled(questions.length, "");
  }

  // ฟังก์ชันสำหรับคำนวณคะแนนแบบทดสอบและแสดงผล
  Future<void> calculateScore() async {
    score = 0;
    for (int i = 0; i < answers.length; i++) {
      // ตรวจสอบคำตอบตามความยาวของ answers
      if (userAnswers[i] == answers[i]) {
        score++;
      }
    }

    // ส่งคะแนนไป backend
    try {
      await http.post(
        Uri.parse('https://apiwebmoss.roverautonomous.com/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'chapter_number': widget.chapter,
          'score': score,
        }),
      );
      print('Score submitted successfully!');
    } catch (e) {
      print('Error submitting score: $e');
      // อาจแสดงข้อความแจ้งเตือนผู้ใช้หากส่งคะแนนไม่สำเร็จ
    }

    // อัปเดต progress ไป backend
    try {
      await http.post(
        Uri.parse('https://apiwebmoss.roverautonomous.com/update_progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'current_chapter': widget.chapter + 1, // อัปเดตเป็น chapter ถัดไป
        }),
      );
      print('Progress updated successfully!');
    } catch (e) {
      print('Error updating progress: $e');
      // อาจแสดงข้อความแจ้งเตือนผู้ใช้หากอัปเดต progress ไม่สำเร็จ
    }

    // แสดงผลคะแนนใน AlertDialog
    // ใช้ await เพื่อรอให้ AlertDialog แสดงผลและถูกปิดก่อนดำเนินการต่อ
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Your Score"), // เปลี่ยนหัวข้อตามที่ผู้ใช้ต้องการ
          content: Text(
            "You scored $score out of ${answers.length}.",
          ), // เปลี่ยนข้อความตามที่ผู้ใช้ต้องการ
          actions: [
            TextButton(
              onPressed: () {
                // Navigator.pop(context); // ปิด dialog แสดงผลคะแนน
                // นำทางไปยัง Chapter3Page ตามที่ผู้ใช้ระบุ
                // โปรดทราบ: หากต้องการไป Chapter ถัดไป ควรเปลี่ยนเป็น ChapterNPage()
                // หรือกลับไปหน้าเลือก Chapter
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GateResultPage(
                      // กลับมาที่ Chapter3Page ตามคำขอ
                      chapter: 5, // กำหนดหมายเลขบทที่ต้องการ
                      username: widget.username,
                    ),
                  ),
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสำหรับส่งข้อความไปที่ n8n webhook
  Future<void> _sendMessageToN8n(StateSetter setModalState) async {
    final userMessage = _chatController.text;
    if (userMessage.isEmpty) return; // ไม่ส่งข้อความถ้าว่างเปล่า

    // อัปเดต UI เพื่อแสดงข้อความของผู้ใช้และสถานะกำลังโหลด
    setModalState(() {
      _chatMessages.add(ChatMessage(text: userMessage, isUser: true));
      _isChatLoading = true;
    });
    _chatController.clear(); // ล้างช่องพิมพ์

    try {
      final url = Uri.parse(
        'https://n8nmoss.roverautonomous.com/webhook/1054bc91-ee04-46fd-94a8-4b2055e6087f',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': widget.username, 'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final botReply = responseBody['reply'] ?? 'Sorry, I did not get that.';

        // อัปเดต UI ด้วยข้อความตอบกลับจาก bot
        setModalState(() {
          _chatMessages.add(ChatMessage(text: botReply, isUser: false));
          questionCount++; // เพิ่มจำนวนครั้งที่ AI ตอบกลับ
        });

        // หาก AI ตอบกลับครบ 3 ครั้งแล้ว ให้แสดงแบบทดสอบ
        if (questionCount >= 3) {
          // รีเซ็ต questionCount เพื่อไม่ให้แสดงแบบทดสอบซ้ำทันที
          // สามารถปรับเปลี่ยน logic ได้ตามต้องการ
          questionCount = 0;
          _showQuiz();
        }
      } else {
        // กรณีเกิดข้อผิดพลาดในการเชื่อมต่อ n8n
        setModalState(() {
          _chatMessages.add(
            ChatMessage(text: 'Error: ${response.statusCode}', isUser: false),
          );
        });
      }
    } catch (e) {
      // กรณีเกิดข้อผิดพลาดอื่นๆ
      setModalState(() {
        _chatMessages.add(
          ChatMessage(text: 'Error: ${e.toString()}', isUser: false),
        );
      });
    } finally {
      // สิ้นสุดการโหลด
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
        // ใช้ StatefulBuilder เพื่อจัดการสถานะภายใน AlertDialog โดยเฉพาะ
        // เพื่อให้อัปเดต UI ของ RadioListTile ได้ถูกต้อง
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: Text("Quiz Time!"),
              content: SingleChildScrollView(
                // ทำให้เนื้อหาเลื่อนได้ถ้ามีคำถามเยอะ
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // วนลูปเพื่อแสดงคำถามและตัวเลือก
                    for (int i = 0; i < questions.length; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(questions[i], style: TextStyle(fontSize: 18)),
                          // แสดงตัวเลือกให้ผู้ใช้เลือก
                          ...options[i].map((option) {
                            return RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue:
                                  userAnswers[i], // ค่า groupValue คือ userAnswers[i] สำหรับคำถามนี้
                              onChanged: (value) {
                                // สำคัญ: ใช้ setModalState เพื่ออัปเดตสถานะภายใน dialog เท่านั้น
                                setModalState(() {
                                  userAnswers[i] =
                                      value!; // อัปเดต userAnswers เมื่อเลือกตัวเลือก
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
                  onPressed: () async {
                    // ทำให้ onPressed เป็น async เพื่อใช้ await
                    // ตรวจสอบว่าผู้ใช้เลือกคำตอบครบทุกข้อแล้วหรือไม่
                    if (userAnswers.every((answer) => answer.isNotEmpty)) {
                      await calculateScore(); // รอให้การคำนวณคะแนนและการแสดงผลคะแนนเสร็จสิ้น
                      Navigator.of(
                        context,
                      ).pop(); // จากนั้นจึงปิด dialog แบบทดสอบ
                    } else {
                      // แสดงข้อความเตือนเมื่อยังไม่ได้เลือกคำตอบครบทุกข้อ
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please select an answer before submitting',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text("Submit"),
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
      isScrollControlled:
          true, // ทำให้ bottom sheet สามารถเลื่อนได้เมื่อคีย์บอร์ดปรากฏ
      builder: (context) {
        // ใช้ StatefulBuilder เพื่อจัดการสถานะภายใน bottom sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                // ปรับ padding ให้หลบ keyboard
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Container(
                height:
                    MediaQuery.of(context).size.height *
                    0.7, // กำหนดความสูงของ bottom sheet
                child: Column(
                  children: [
                    // ส่วนแสดงผลข้อความแชท
                    Expanded(
                      child: ListView.builder(
                        reverse: true, // แสดงข้อความล่าสุดข้างล่าง
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, index) {
                          // เข้าถึงข้อความแบบย้อนกลับสำหรับ reverse: true
                          final message = _chatMessages.reversed
                              .toList()[index];
                          return Align(
                            alignment: message.isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.symmetric(
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
                                      // ใช้ MarkdownBody เพื่อแสดงข้อความที่รองรับ Markdown
                                      data: message.text,
                                      shrinkWrap: true,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                    // แสดง CircularProgressIndicator เมื่อกำลังโหลดข้อความ
                    if (_isChatLoading)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    // ส่วนสำหรับพิมพ์ข้อความ
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
                              onSubmitted: (_) => _sendMessageToN8n(
                                setModalState,
                              ), // ส่งข้อความเมื่อกด Enter
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () => _sendMessageToN8n(
                              setModalState,
                            ), // ส่งข้อความเมื่อกดปุ่มส่ง
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
      // ปุ่มลอยสำหรับเปิดหน้าต่างแชท
      floatingActionButton: FloatingActionButton(
        onPressed: _showChatDialog,
        child: Icon(Icons.chat_bubble_outline),
        tooltip: 'Chat with AI Assistant',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text("ถ้าคุณถูกชักชวนให้สูบบุหรี่ไฟฟ้า "),
              // เพิ่มปุ่มสำหรับเรียกแบบทดสอบด้วยตนเอง เพื่อการทดสอบ

              // 🧍 Character Image
              Image.asset(
                'assets/images/buddy_8.png', // Make sure the image is added to pubspec.yaml
                height: 400,
              ),

              SizedBox(height: 10),

              // 💬 Text beside or below character
              Text(
                "คุณจะทำอย่างไร",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30),

              Text(
                "สวัสดี! ฉันพร้อมจะช่วยให้คำปรึกษาแล้วนะ เปิดกล่องข้อความด้างล่างเพื่อคุยกับฉันเลย",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
