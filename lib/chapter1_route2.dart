// lib/chapter1_route2.dart - บทที่ 1 สำหรับเส้นทางที่ 2
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่รวม
import 'constants.dart'; // นำเข้า AppConstants

class Chapter1Route2Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId; // รับ routeId เข้ามา (จะเป็น 2)
  final VoidCallback onFinished;

  Chapter1Route2Page({
    required this.chapter,
    required this.username,
    required this.routeId,
    required this.onFinished,
  });

  @override
  _Chapter1Route2PageState createState() => _Chapter1Route2PageState();
}

class _Chapter1Route2PageState extends State<Chapter1Route2Page> {
  // เนื้อหาสำหรับเส้นทางที่ 2 (แตกต่างจากเส้นทางที่ 1)
  List<String> questions = [
    "ในเส้นทางที่ 2 นี้ การสื่อสารเรื่องบุหรี่ไฟฟ้ากับเพื่อน ควรเน้นเรื่องใดมากที่สุด?",
    // "วิธีการใดที่ช่วยให้เพื่อนรับฟังความเห็นเรื่องบุหรี่ไฟฟ้าได้ดีที่สุด?",
    // "ถ้าเพื่อนรู้สึกไม่พอใจเมื่อพูดถึงบุหรี่ไฟฟ้า ควรทำอย่างไร?",
    // "ข้อมูลสุขภาพเกี่ยวกับบุหรี่ไฟฟ้าที่เพื่อนวัยรุ่นเชื่อถือได้ควรมาจากแหล่งใด?",
    // "สถานการณ์ใดที่ควรหลีกเลี่ยงการพูดคุยเรื่องบุหรี่ไฟฟ้ากับเพื่อน?",
    // "หากเพื่อนยังคงยืนยันที่จะสูบบุหรี่ไฟฟ้า ควรตอบกลับอย่างไร?",
    // "ข้อใดคือสัญญาณว่าเพื่อนอาจกำลังติดบุหรี่ไฟฟ้า?",
    // "การสนับสนุนเพื่อนที่ต้องการเลิกบุหรี่ไฟฟ้าควรทำอย่างไร?",
    // "บทบาทของเราในการช่วยให้เพื่อนไม่สูบบุหรี่ไฟฟ้าคืออะไร?",
    // "สรุปแนวทางการสื่อสารที่มีประสิทธิภาพที่สุดกับเพื่อนเรื่องบุหรี่ไฟฟ้าคือ?",
  ];

  List<List<String>> options = [
    ["ข้อเสียด้านการเงิน", "ผลกระทบต่ออนาคต", "ข้อมูลสุขภาพที่เป็นจริง", "การโดนลงโทษจากโรงเรียน"],
    // ["บังคับให้หยุด", "ใช้เหตุผลและข้อมูล", "ขู่ว่าจะบอกครู", "เมินเฉย"],
    // ["เลิกพูดทันที", "พยายามทำความเข้าใจความรู้สึก", "โต้เถียงกลับ", "เดินหนีไป"],
    // ["บล็อกเกอร์รีวิวบุหรี่ไฟฟ้า", "องค์กรสาธารณสุข", "ร้านขายบุหรี่ไฟฟ้า", "เพื่อนที่สูบอยู่แล้ว"],
    // ["ขณะที่กำลังสูบอยู่", "ในวงสนทนากลุ่มใหญ่", "ในเวลาที่ผ่อนคลายและเป็นส่วนตัว", "เมื่อมีคนเยอะๆ"],
    // ["เลิกคบเพื่อนคนนั้น", "ให้ข้อมูลเพิ่มเติมอย่างใจเย็น", "ตัดสินและตำหนิ", "ชวนไปลองสิ่งอื่น"],
    // ["กระหายที่จะสูบตลอดเวลา", "มีเงินมากขึ้น", "เรียนดีขึ้น", "เข้าสังคมได้ดีขึ้น"],
    // ["ซื้อบุหรี่ไฟฟ้าให้เลิกไม่ได้", "ให้กำลังใจและสนับสนุนอย่างสม่ำเสมอ", "สั่งให้เลิกทันที", "เยาะเย้ยหากล้มเหลว"],
    // ["ตัดสินใจแทนเพื่อน", "ให้ข้อมูลและเป็นตัวอย่างที่ดี", "หลีกเลี่ยงการพูดถึง", "พาเพื่อนไปลองสูบ"],
    // ["ใช้ข้อมูลเชิงข่มขู่", "สื่อสารอย่างเปิดใจและเข้าใจ", "พูดแบบไม่สนใจ", "สั่งให้เพื่อนทำตาม"],
  ];

  List<String> answers = [
    "ข้อมูลสุขภาพที่เป็นจริง",
    // "ใช้เหตุผลและข้อมูล",
    // "พยายามทำความเข้าใจความรู้สึก",
    // "องค์กรสาธารณสุข",
    // "ในเวลาที่ผ่อนคลายและเป็นส่วนตัว",
    // "ให้ข้อมูลเพิ่มเติมอย่างใจเย็น",
    // "กระหายที่จะสูบตลอดเวลา",
    // "ให้กำลังใจและสนับสนุนอย่างสม่ำเสมอ",
    // "ให้ข้อมูลและเป็นตัวอย่างที่ดี",
    // "สื่อสารอย่างเปิดใจและเข้าใจ",
  ];

  late List<String> userAnswers; // Initialize userAnswers based on the number of questions
  int score = 0;
  int currentIndex = 0;
  String characterImage = 'assets/images/buddy_8.png'; // ใช้รูปเดิมไปก่อน
  bool answered = false;
  bool isCorrect = false;

  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3',
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3',
  )..preload = 'auto';

  final List<String> questionImages = [
    'assets/images/question1_r2.png', // รูปใหม่สำหรับ Route 2
    'assets/images/question2_r2.jpg',
    'assets/images/question3_r2.png',
    'assets/images/question4_r2.jpg',
    'assets/images/question5_r2.jpg',
    'assets/images/question6_r2.png',
    'assets/images/question7_r2.jpg',
    'assets/images/question8_r2.png',
    'assets/images/question9_r2.jpg',
    'assets/images/question10_r2.png',
  ];

  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(questions.length, ""); // Initialize userAnswers correctly
  }

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
    if (answered) return; // ป้องกันการส่งคำตอบซ้ำ

    bool correct = selected == answers[currentIndex];
    userAnswers[currentIndex] = selected;

    setState(() {
      answered = true;
      isCorrect = correct;
      characterImage = correct
          ? 'assets/images/buddy_happy.png'
          : 'assets/images/buddy_sad.png';
    });

    if (kIsWeb) {
      correct ? playCorrect() : playWrong();
    }

    if (correct) {
      score++;
    }

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      answered = false;
      characterImage = 'assets/images/buddy_8.png';
    });

    // ตรวจสอบว่าคำถามทั้งหมดในบทเรียนปัจจุบันถูกตอบแล้วหรือไม่
    bool isCurrentChapterQuizFinished = (currentIndex + 1 >= questions.length);

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
                'chapter': widget.chapter,
                'score': score, // คะแนนรวมที่ได้ในบทเรียนนี้
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
        print('Error submitting score: $e');
    }

    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex++;
      });
    } else {
      print('Chapter ${widget.chapter} (Route ${widget.routeId}) finished. Final score: $score');

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("คะแนนของคุณ"),
          content: Text("คุณได้ $score จาก ${questions.length} คะแนน"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GateResultPage(
                      username: widget.username,
                      nextChapter: chapterToAdvanceTo,
                      nextRouteId: routeIdToAdvanceTo,
                      message: 'จบบทที่ ${widget.chapter} เส้นทางที่ ${widget.routeId} แล้ว 🎉',
                      chapterDescription: 'กำลังเข้าสู่บทต่อไป...',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เส้นทางที่ ${widget.routeId} - บทที่ ${widget.chapter} – ข้อที่ ${currentIndex + 1}/${questions.length}',
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
              if (currentIndex < questionImages.length && questionImages[currentIndex].isNotEmpty)
                Image.asset(questionImages[currentIndex], height: 200),
              const SizedBox(height: 20),
              Text(
                questions[currentIndex],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              ...options[currentIndex].map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: userAnswers[currentIndex], // ถูกต้อง
                  onChanged: answered ? null : (_) => submitAnswer(option),
                  tileColor: answered
                      ? (option == answers[currentIndex]
                            ? Colors.green.withOpacity(0.2)
                            : (option == userAnswers[currentIndex] // ถูกต้อง
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