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
    "ถ้าต้องการรู้ว่า “บุหรี่ไฟฟ้าอันตรายหรือไม่” ควรหาข้อมูลจากที่ใด?",
    "หากสงสัยเรื่องผลเสียของบุหรี่ไฟฟ้า ควรถามใครดีที่สุด ?",
    "แหล่งใดต่อไปนี้ น่าเชื่อถือน้อยที่สุด?",
    "คำค้นหาข้อใดจะให้ข้อมูลเกี่ยวกับผลเสียของบุหรี่ไฟฟ้า?",
    "ถ้าเว็บไซต์ใดไม่มีชื่อผู้เขียนและวันเผยแพร่ ข้อมูลนั้นควร…?",
    "หากต้องการเปรียบเทียบข้อมูลจากหลายแหล่ง ควรทำอย่างไร ?",
    //"การเข้าถึงแหล่งข้อมูลแบบใดมีโอกาสได้ข้อมูลลวงมากที่สุด?",
    //"การเสิร์ชหา “โทษบุหรี่ไฟฟ้าในวัยรุ่น” บน Google คือการฝึกทักษะใด?",
    //"ข้อใดไม่ควรทำเมื่อพบข้อมูลบนอินเทอร์เน็ต?",
    //"ถ้าต้องการหาข้อมูลสุขภาพล่าสุด ควรใช้แหล่งใด ?",
  ];

  List<List<String>> options = [
    [
      "เว็บไซต์รีวิววัยรุ่น ",
      "เว็บไซต์ของกระทรวงสาธารณสุข",
      "โซเชียลมีเดีย ",
      "เพื่อนสนิท ",
    ],
    [
      "พนักงานร้านขายบุหรี่",
      "เพื่อนในห้อง ",
      "ยูทูบเบอร์",
      "คุณครูหรือบุคลากรสาธารณสุข",
    ],
    [
      "เว็บไซต์ข่าวสุขภาพ",
      "บทความจากกระทรวงสาธารณสุข",
      "โฆษณาขายบุหรี่ไฟฟ้า",
      "หนังสือเรียนวิทยาศาสตร์",
    ],
    [
      "บุหรี่ไฟฟ้าราคา",
      "บุหรี่ไฟฟ้าอันตราย",
      "รีวิวบุหรี่ไฟฟ้า",
      "กลิ่นบุหรี่ไฟฟ้ายอดนิยม",
    ],
    [
      "ตรวจสอบความน่าเชื่อถือก่อน",
      "ใช้ได้แน่นอน",
      "ไม่ต้องสนใจ",
      "แชร์ต่อทันที",
    ],
    [
      "อ่านเฉพาะเว็บที่สนใจ",
      "เชื่อแหล่งที่ดูทันสมัย",
      "หาข้อมูลจากหลายแหล่งและเปรียบเทียบ",
      "ถามเพื่อนว่าคิดอย่างไร",
    ],
    //["เว็บไซต์ราชการ", "บทเรียนจากโรงเรียน", "วิดีโอขายสินค้า", "หนังสือเรียน"],
    //[
    //  "การเข้าถึงข้อมูล",
    //  "การใช้สื่อออนไลน์",
    //  "การจัดการอารมณ์",
    //  "การออกกำลังกาย",
    //],
    //[
    //  "อ่านเนื้อหาทั้งหมด",
    //  "ตรวจสอบว่าแหล่งข้อมูลมาจากที่ใด",
    //  "แชร์ข้อมูลก่อนอ่าน",
    //  "ดูวันที่เผยแพร่",
    //],
    //[
    //  "โฆษณาใน TikTok",
    //  "คำบอกเล่าจากเพื่อน",
    //  "เว็บไซต์ของโรงพยาบาล",
    //  "ฟอรัมสนทนาออนไลน์",
    //],
  ];

  List<String> answers = [
    "เว็บไซต์ของกระทรวงสาธารณสุข",
    "คุณครูหรือบุคลากรสาธารณสุข",
    "โฆษณาขายบุหรี่ไฟฟ้า",
    "บุหรี่ไฟฟ้าอันตราย",
    "ตรวจสอบความน่าเชื่อถือก่อน",
    "หาข้อมูลจากหลายแหล่งและเปรียบเทียบ",
    //"วิดีโอขายสินค้า",
    //"การเข้าถึงข้อมูล",
    //"แชร์ข้อมูลก่อนอ่าน",
    //"เว็บไซต์ของโรงพยาบาล",
  ];

  late List<String>
  userAnswers; // Initialize userAnswers based on the number of questions
  int score = 0;
  int currentIndex = 0;
  String characterImage = 'assets/images/buddy_8.png'; // ใช้รูปเดิมไปก่อน
  bool answered = false;
  bool isCorrect = false;
  final html.AudioElement backgroundAudio =
      html.AudioElement('assets/sounds/background.mp3')
        ..loop = true
        ..autoplay = true
        ..volume = 0.3;

  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3',
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3',
  )..preload = 'auto';

  final List<String> questionImages = [
    'assets/images/question1_r2.jpg', // รูปใหม่สำหรับ Route 2
    'assets/images/question2_r2.jpg',
    'assets/images/question3_r2.jpg',
    'assets/images/question4_r2.webp',
    'assets/images/question5_r2.webp',
    'assets/images/question6_r2.jpg',
    //'assets/images/question7_r2.jpg',
    //'assets/images/question8_r2.jpg',
    //'assets/images/question9_r2.jpg',
    //'assets/images/question10_r2.jpg',
  ];

  @override
  void initState() {
    super.initState();
    backgroundAudio.play();
    userAnswers = List.filled(
      questions.length,
      "",
    ); // Initialize userAnswers correctly
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

  @override
  void dispose() {
    backgroundAudio.pause();
    backgroundAudio.src = '';
    super.dispose();
  }

  void submitAnswer(String selected) async {
    if (answered) return; // ป้องกันการส่งคำตอบซ้ำ

    bool correct = selected == answers[currentIndex];
    userAnswers[currentIndex] = selected;

    setState(() {
      answered = true;
      isCorrect = correct;
      characterImage = correct
          ? 'assets/images/buddy_8c.gif'
          : 'assets/images/buddy_8w.gif';
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
        print(
          'Failed to submit score: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error submitting score: $e');
    }

    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex++;
      });
    } else {
      print(
        'Chapter ${widget.chapter} (Route ${widget.routeId}) finished. Final score: $score',
      );

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
                      message:
                          'จบบทที่ ${widget.chapter} เส้นทางที่ ${widget.routeId} แล้ว 🎉',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(characterImage, height: 400),
                  const SizedBox(width: 20),
                  if (currentIndex < questionImages.length)
                    Image.asset(questionImages[currentIndex], height: 400),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                questions[currentIndex],
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              // Display options
              ...options[currentIndex].map((option) {
                return Center(
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: answered
                        ? (option == answers[currentIndex]
                              ? Colors.green.withOpacity(0.2)
                              : (option == userAnswers[currentIndex]
                                    ? Colors.red.withOpacity(0.2)
                                    : null))
                        : null,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: userAnswers[currentIndex],
                        onChanged: answered
                            ? null
                            : (_) => submitAnswer(option!),
                      ),
                    ),
                  ),
                );
              }).toList(),

              // Display answer result
              if (answered)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    isCorrect ? '✅ ตอบถูกต้อง 🎉' : '❌ ผิด ไม่เป็นไรนะ 😢',
                    style: TextStyle(
                      fontSize: 25,
                      color: isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
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
