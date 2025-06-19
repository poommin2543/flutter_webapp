import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class Chapter1Page extends StatefulWidget {
  final int chapter;
  final String username;
  final VoidCallback onFinished;
  
  Chapter1Page({
    required this.chapter,
    required this.username,
    required this.onFinished,
  });

  @override
  _Chapter1PageState createState() => _Chapter1PageState();
}

class _Chapter1PageState extends State<Chapter1Page> {
  List<String> questions = [
    "จากข้อมูลในภาพ ข้อใด 'ไม่ถูกต้อง' เกี่ยวกับบุหรี่ไฟฟ้า?",
    "ผลกระทบต่อเยาวชนจากการใช้บุหรี่ไฟฟ้า ตามข้อมูลในภาพคือข้อใด?"
    
  ];

  List<List<String>> options = [
    ["บุหรี่ไฟฟ้าช่วยให้เลิกสูบบุหรี่ธรรมดาได้แน่นอน", 
    "บุหรี่ไฟฟ้ามีสารที่เป็นอันตรายต่อร่างกาย", 
    "บุหรี่ไฟฟ้าเป็นสิ่งผิดกฎหมาย", 
    "บุหรี่ไฟฟ้ามีผลเสียต่อหัวใจและหลอดเลือด"],
    ["เยาวชนมีแนวโน้มเข้าสู่วงการกีฬา", 
    "เยาวชนจะไม่ติดนิโคติน", 
    "เยาวชนมีความเสี่ยงใช้สารเสพติดเพิ่มขึ้น", 
    "ไม่มีผลต่อพฤติกรรมของเยาวชน"],
    
  ];

  List<String> answers = ["บุหรี่ไฟฟ้าช่วยให้เลิกสูบบุหรี่ธรรมดาได้แน่นอน","เยาวชนมีความเสี่ยงใช้สารเสพติดเพิ่มขึ้น"];
  List<String> userAnswers = ["",""];

  int score = 0;

  void calculateScore() async {
  score = 0;
  for (int i = 0; i < answers.length; i++) {
    if (userAnswers[i] == answers[i]) {
      score++;
    }
  }

  // ส่งคะแนนไป backend
    await http.post(
      Uri.parse('http://127.0.0.1:8080/submit_score'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'chapter_number': widget.chapter,
        'score': score,
      }),
    );
    //update_progress
    await http.post(
      Uri.parse('http://127.0.0.1:8080/update_progress'),
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
            Navigator.pop(context); // กลับไปหน้าเลือก Chapter
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.asset('assets/image1.png'),
                Image.asset('assets/image2.jpg'),
                Image.asset('assets/image3.jpg'),
                SizedBox(height: 20),

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
                ElevatedButton(
                  onPressed: calculateScore,
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
