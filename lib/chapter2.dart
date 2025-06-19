import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'chapter4.dart';
class Chapter2Page extends StatefulWidget {
  final int chapter;
  final String username;
  final VoidCallback onFinished;
  
  Chapter2Page({
    required this.chapter,
    required this.username,
    required this.onFinished,
  });
  @override
  _Chapter2PageState createState() => _Chapter2PageState();
}

class _Chapter2PageState extends State<Chapter2Page> {
  late YoutubePlayerController _controller;

  List<String> questions = [
    "จุดประสงค์หลักของหนังสั้นเรื่อง 'ควันหวานอันตราย' คือข้อใด?",
  ];

  List<List<String>> options = [
    ["แนะนำวิธีใช้บุหรี่ไฟฟ้าอย่างปลอดภัย", "เตือนภัยและให้ความรู้เกี่ยวกับอันตรายของบุหรี่ไฟฟ้า", "ส่งเสริมบุหรี่ไฟฟ้าแทนบุหรี่ธรรมดา", "รีวิวผลิตภัณฑ์บุหรี่ไฟฟ้ารุ่นใหม่"],
  ];

  List<String> answers = ["เตือนภัยและให้ความรู้เกี่ยวกับอันตรายของบุหรี่ไฟฟ้า",];
  List<String> userAnswers = ["", ""];

  int score = 0;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'AvcAVT_XQA0',
      params: YoutubePlayerParams(
        showFullscreenButton: false,
        showControls: false, // ซ่อนแถบควบคุม
        mute: false, // เปิดเสียง

      ),
    );
    // เริ่มเล่นวิดีโอโดยการเรียก play() หลังจากสร้างตัวควบคุม
    // _controller = YoutubePlayerController(
    //   params: YoutubePlayerParams(
    //     mute: false,
    //     showControls: false,
    //     showFullscreenButton: false,
    //   ),
    // );

    // _controller.loadVideoById(videoId: 'AvcAVT_XQA0');
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void calculateScore() async {
  score = 0;
  for (int i = 0; i < answers.length; i++) {
    if (userAnswers[i] == answers[i]) {
      score++;
    }
  }

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
    //update_progress
    await http.post(
      Uri.parse('https://apiwebmoss.roverautonomous.com/update_progress'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'current_chapter': widget.chapter + 1,
      }),
    );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Your Score"),
      content: Text("You scored $score out of ${answers.length}."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // ปิด dialog
            // Navigator.pop(context); // กลับไปหน้าเลือก Chapter
            Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chapter4Page(
                      chapter: 4, // กำหนดหมายเลขบทที่ต้องการ (ในที่นี้คือ Chapter 1)
                      username: widget.username,
                      onFinished: () {
                        // ตัวอย่างเมื่อเสร็จสิ้นการทำ Chapter3 แล้ว
                      },
                    ),
                  ),
                );
          },
          child: Text('OK'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chapter ${widget.chapter}')),
      body: SingleChildScrollView(
        // ใช้ SingleChildScrollView เพื่อเลื่อนหน้าจอ
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // แสดงวีดีโอ
              YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
              SizedBox(height: 20),

              // คำถามและตัวเลือกสำหรับ Chapter 2
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
            ],
          ),
        ),
      ),
    );
  }
}
