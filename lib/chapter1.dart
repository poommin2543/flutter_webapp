// lib/chapter1.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่รวม
import 'constants.dart'; // นำเข้า AppConstants

class Chapter1Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId; // เพิ่ม: รับ routeId เข้ามา
  final VoidCallback onFinished;

  Chapter1Page({
    required this.chapter,
    required this.username,
    required this.routeId, // กำหนดให้รับ routeId
    required this.onFinished,
  });

  @override
  _Chapter1PageState createState() => _Chapter1PageState();
}

class _Chapter1PageState extends State<Chapter1Page> {
  List<String> questions = [
    "หากต้องการข้อมูลล่าสุดเกี่ยวกับบุหรี่ไฟฟ้า ควรเลือกค้นหาจากแหล่งใดเป็นอันดับแรก?",
    "การเข้าถึงข้อมูลรูปแบบใดในปัจจุบันเกี่ยวกับบุหรี่ไฟฟ้าที่เข้าถึงง่ายที่สุด? (คำตอบที่ถูกต้องคือ 'สื่อสังคมออนไลน์')", // เพิ่มคำตอบที่ถูกต้องชั่วคราว
    "คำค้น (Keyword) ใดให้ข้อมูลเฉพาะเจาะจงเกี่ยวกับอันตรายของบุหรี่ไฟฟ้าในวัยรุ่นมากที่สุด?",
    "หากคุณต้องการรู้ “กฎหมายไทยเกี่ยวกับบุหรี่ไฟฟ้า” คำค้นใดเหมาะสมที่สุด?",
    "ถ้าค้นหาด้วยคำว่า “กฎหมายห้ามสูบบุหรี่ไฟฟ้าในโรงเรียน” สิ่งที่คุณคาดว่าจะเจอได้แก่อะไร?",
    "ตัวอย่างของ “ข้อมูลส่วนบุคคล” ที่ไม่เหมาะกับการใช้ในการตัดสินใจเรื่องบุหรี่ไฟฟ้า คืออะไร?",
    "ในกรณีที่มีข่าวจาก 2 แหล่งข้อมูลให้ข้อมูลไม่ตรงกันเกี่ยวกับอันตรายของบุหรี่ไฟฟ้า คุณควรทำอย่างไร?",
    "หากต้องการเปรียบเทียบข้อมูลจากหลายแหล่งเกี่ยวกับบุหรี่ไฟฟ้า ควรทำอย่างไร?",
    "ข้อใดคือวิธีที่ดีที่สุดในการเข้าถึงข้อมูลที่ถูกต้อง?",
    "ข้อมูลเกี่ยวกับบุหรี่ไฟฟ้าที่น่าเชื่อถือได้มากที่สุดมาจากหน่วยงานใด?",
  ];

  List<List<String>> options = [
    [
      "หนังสือเรียน",
      "เว็บไซต์ของหน่วยงานสุขภาพ",
      "โพสต์จากอินฟลูเอนเซอร์",
      "บทความจากนิตยสารเมื่อ 5 ปีก่อน",
    ],
    ["ข่าวสารจากโทรทัศน์", "สื่อสังคมออนไลน์", "เว็บไซต์", "ข้อมูลส่วนบุคคล"],
    [
      "บุหรี่",
      "อันตรายจากบุหรี่ไฟฟ้า",
      "อันตรายบุหรี่ไฟฟ้าในวัยรุ่น",
      "วัยรุ่น",
    ],
    [
      "กฎหมายบุหรี่ไฟฟ้าในประเทศไทย",
      "vape ดีกว่าบุหรี่",
      "สูบบุหรี่ในโรงเรียน",
      "บุหรี่ไฟฟ้า",
    ],
    [
      "บทความวิจารณ์จากบล็อก",
      "คลิปวิดีโอล้อเลียน",
      "โพสต์ใน Facebook",
      "ระเบียบของกระทรวงศึกษาธิการ",
    ],
    [
      "ความคิดเห็นจากเพื่อนที่เคยลอง",
      "รายงานจากกระทรวงสาธารณสุข",
      "ข้อมูลจากองค์กรอนามัยโลก (WHO)",
      "สรุปผลการวิจัยจากโรงพยาบาล",
    ],
    [
      "เลือกเชื่อข่าวที่ชอบ",
      "ตรวจสอบแหล่งข้อมูลเพิ่มเติมทั้งสองแหล่ง",
      "เชื่อข่าวที่มีภาพประกอบเยอะ",
      "แชร์ข่าวทันทีโดยไม่ต้องตรวจสอบ",
    ],
    [
      "อ่านแค่เว็บแรกที่เจอ",
      "ค้นจากหลายเว็บไซต์และเปรียบเทียบข้อมูล",
      "ถามเพื่อน",
      "เชื่อโพสต์ใน TikTok",
    ],
    [
      "อ่านเฉพาะพาดหัว",
      "กดลิงก์ที่แชร์มา",
      "ใช้คำค้นที่เจาะจง และตรวจสอบหลายแหล่ง",
      "ถามเพื่อนในกลุ่ม Line",
    ],
    [
      "ร้านค้าออนไลน์ที่จำหน่ายบุหรี่ไฟฟ้า",
      "กลุ่มผู้ใช้ในโซเชียลมีเดีย",
      "สำนักงานคณะกรรมการอาหารและยา (อย.)",
      "ยูทูบเบอร์ที่รีวิวบุหรี่ไฟฟ้า",
    ],
  ];

  List<String> answers = [
    "เว็บไซต์ของหน่วยงานสุขภาพ",
    "สื่อสังคมออนไลน์", // แก้คำตอบให้ตรงกับ Backend
    "อันตรายบุหรี่ไฟฟ้าในวัยรุ่น",
    "กฎหมายบุหรี่ไฟฟ้าในประเทศไทย",
    "ระเบียบของกระทรวงศึกษาธิการ",
    "ความคิดเห็นจากเพื่อนที่เคยลอง",
    "ตรวจสอบแหล่งข้อมูลเพิ่มเติมทั้งสองแหล่ง",
    "ค้นจากหลายเว็บไซต์และเปรียบเทียบข้อมูล",
    "ใช้คำค้นที่เจาะจง และตรวจสอบหลายแหล่ง",
    "สำนักงานคณะกรรมการอาหารและยา (อย.)",
  ];

  List<String> userAnswers = ["", "", "", "", "", "", "", "", "", ""];
  int score = 0;
  int currentIndex = 0;
  String characterImage = 'assets/images/buddy_8.png';
  bool answered = false;
  bool isCorrect = false;

  // สำหรับ Web, path ของ Audio ต้องสัมพันธ์กับ web/index.html
  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3', // ตรวจสอบว่ามีไฟล์นี้ใน web/assets/sounds
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3', // ตรวจสอบว่ามีไฟล์นี้ใน web/assets/sounds
  )..preload = 'auto';

  final List<String> questionImages = [
    'assets/images/question1.png',
    'assets/images/question2.jpg',
    'assets/images/question3.jpg',
    'assets/images/question4.png',
    'assets/images/question5.png',
    'assets/images/question6.jpg',
    'assets/images/question7.webp',
    'assets/images/question8.jpg',
    'assets/images/question9.jpg',
    'assets/images/question10.jpg', // เพิ่มรูปสำหรับข้อ 10 ถ้ามี
  ];

  void playCorrect() {
    if (kIsWeb) {
      correctAudio.pause();
      correctAudio.currentTime = 0;
      correctAudio.play();
    }
  }

  void playWrong() {
    if (kIsWeb) {
      wrongAudio.pause();
      wrongAudio.currentTime = 0;
      wrongAudio.play();
    }
  }

  void submitAnswer(String selected) async {
    bool correct = selected == answers[currentIndex];
    userAnswers[currentIndex] = selected;

    setState(() {
      answered = true;
      isCorrect = correct;
      characterImage = correct
          ? 'assets/images/buddy_happy.png' // รูปบัดดี้มีความสุข
          : 'assets/images/buddy_sad.png'; // รูปบัดดี้เศร้า
    });

    if (correct) {
      playCorrect();
    } else {
      playWrong();
    }

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      answered = false;
      characterImage = 'assets/images/buddy_8.png'; // กลับไปเป็นรูปปกติ
    });

    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex++;
      });
    } else {
      calculateScore();
    }
  }

  void calculateScore() async {
    score = 0;
    for (int i = 0; i < answers.length; i++) {
      if (userAnswers[i] == answers[i]) score++;
    }

    // ส่งคะแนนไป backend พร้อม route_id
    await http.post(
      Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'route_id': widget.routeId, // ส่ง route_id
        'chapter_number': widget.chapter,
        'score': score,
      }),
    );

    // อัปเดต progress ไป backend พร้อม route_id (ซึ่งคือ routeId เดิม)
    await http.post(
      Uri.parse('${AppConstants.API_BASE_URL}/update_progress'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'current_chapter': widget.chapter + 1,
        'current_route_id': widget.routeId, // ส่ง routeId ปัจจุบัน
      }),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("คะแนนของคุณ"),
        content: Text("คุณได้ $score จาก ${answers.length} คะแนน"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // นำทางไปยัง GateResultPage ที่รวมไว้
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GateResultPage(
                    username: widget.username,
                    nextChapter: widget.chapter + 1,
                    nextRouteId: widget.routeId, // ส่ง routeId ปัจจุบัน
                    message: 'จบบทที่ ${widget.chapter} แล้ว 🎉',
                    chapterDescription:
                        'บททดสอบเกี่ยวกับความเข้าใจเกี่ยวกับบุหรี่ไฟฟ้า', // คำอธิบายสำหรับบทที่ 2
                  ),
                ),
              );
            },
            child: const Text('ไปต่อ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'บทที่ ${widget.chapter} – ข้อที่ ${currentIndex + 1}/${questions.length}',
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset(characterImage, height: 300),
              const SizedBox(height: 20),

              if (currentIndex < questionImages.length)
                Image.asset(questionImages[currentIndex], height: 200),

              const SizedBox(height: 20),
              Text(
                questions[currentIndex],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // จัดข้อความให้อยู่กึ่งกลาง
              ),

              ...options[currentIndex].map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: answered ? answers[currentIndex] : null,
                  onChanged: answered ? null : (_) => submitAnswer(option),
                  tileColor: answered
                      ? (option == answers[currentIndex]
                            ? Colors.green.withOpacity(0.2)
                            : (option == userAnswers[currentIndex]
                                  ? Colors.red.withOpacity(0.2)
                                  : null))
                      : null,
                );
              }).toList(),

              if (answered)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    isCorrect ? '✅ ตอบถูกต้อง 🎉' : '❌ ผิด ลองใหม่นะ 😢',
                    style: TextStyle(
                      fontSize: 20,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
