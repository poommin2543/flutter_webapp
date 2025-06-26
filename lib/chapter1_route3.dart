// lib/chapter1_route3.dart - บทที่ 1 สำหรับเส้นทางที่ 3
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'gate_result_page.dart';
import 'constants.dart';

class Chapter1Route3Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId; // รับ routeId เข้ามา (จะเป็น 3)
  final VoidCallback onFinished;

  Chapter1Route3Page({
    required this.chapter,
    required this.username,
    required this.routeId,
    required this.onFinished,
  });

  @override
  _Chapter1Route3PageState createState() => _Chapter1Route3PageState();
}

class _Chapter1Route3PageState extends State<Chapter1Route3Page> {
  // เนื้อหาสำหรับเส้นทางที่ 3 (แตกต่างจากเส้นทางที่ 1 และ 2)
  List<String> questions = [
    "ในเส้นทางที่ 3 นี้ การสร้างความตระหนักรู้เรื่องบุหรี่ไฟฟ้าในสังคมควรเริ่มต้นอย่างไร?",
    // "วิธีการใดที่ช่วยกระจายข้อมูลสุขภาพเกี่ยวกับบุหรี่ไฟฟ้าในวงกว้างได้อย่างมีประสิทธิภาพ?",
    // "กลุ่มเป้าหมายหลักในการรณรงค์เรื่องบุหรี่ไฟฟ้าในโรงเรียนคือใคร?",
    // "หากต้องการจัดกิจกรรมรณรงค์ ควรเน้นรูปแบบใดที่ดึงดูดเยาวชน?",
    // "การทำงานร่วมกับหน่วยงานภาครัฐหรือเอกชนมีประโยชน์อย่างไรในการรณรงค์?",
    // "ข้อใดคือข้อความรณรงค์ที่สร้างสรรค์และน่าจดจำ?",
    // "การใช้สื่อสังคมออนไลน์ในการรณรงค์ควรทำอย่างไรให้เกิดผลดีที่สุด?",
    // "หากได้รับข้อมูลเท็จเกี่ยวกับบุหรี่ไฟฟ้า ควรตอบสนองอย่างไร?",
    // "ความท้าทายหลักในการรณรงค์เรื่องบุหรี่ไฟฟ้าในปัจจุบันคืออะไร?",
    // "วิสัยทัศน์ของคุณในการสร้างสังคมปลอดบุหรี่ไฟฟ้าคืออะไร?",
  ];

  List<List<String>> options = [
    ["เริ่มจากกลุ่มเล็กๆ ในโรงเรียน", "จัดกิจกรรมใหญ่โตทันที", "รอให้คนอื่นเริ่มก่อน", "ไม่ทำอะไรเลย"],
    // ["แจกแผ่นพับ", "จัดประชุมใหญ่", "ใช้สื่อดิจิทัลและกิจกรรมเชิงรุก", "พูดคุยเป็นรายบุคคล"],
    // ["ผู้บริหารโรงเรียน", "นักเรียนและผู้ปกครอง", "ครูอาจารย์", "ชุมชนรอบโรงเรียน"],
    // ["การบรรยายวิชาการ", "กิจกรรมสร้างสรรค์และมีส่วนร่วม", "การบังคับให้เข้าร่วม", "การแจกรางวัลอย่างเดียว"],
    // ["ทำให้งานใหญ่ขึ้น", "เพิ่มงบประมาณ", "ขยายเครือข่ายและความน่าเชื่อถือ", "ไม่มีประโยชน์"],
    // ["บุหรี่ไฟฟ้าฆ่าคุณ", "ไม่ลอง ไม่เสี่ยง ชีวิตปลอดภัย", "สูบเลย สนุกดี", "ใครๆ ก็สูบ"],
    // ["โพสต์บ่อยๆ", "สร้างเนื้อหาน่าสนใจและเป็นประโยชน์", "แชร์ข่าวลือ", "โต้เถียงกับผู้เห็นต่าง"],
    // ["โต้เถียงกลับ", "ตรวจสอบและแก้ไขข้อมูลอย่างสุภาพ", "เชื่อทันที", "ส่งต่อให้ผู้อื่น"],
    // ["งบประมาณจำกัด", "การเข้าถึงเยาวชนยาก", "ข้อมูลที่คลาดเคลื่อนและสื่อการตลาด", "ขาดการสนับสนุน"],
    // ["ทุกคนเลิกสูบ", "ไม่มีบุหรี่ไฟฟ้าขาย", "คนเข้าใจถึงอันตรายและเลือกที่จะไม่สูบ", "ไม่มีคนรู้จักสูบ"],
  ];

  List<String> answers = [
    "เริ่มจากกลุ่มเล็กๆ ในโรงเรียน",
    // "ใช้สื่อดิจิทัลและกิจกรรมเชิงรุก",
    // "นักเรียนและผู้ปกครอง",
    // "กิจกรรมสร้างสรรค์และมีส่วนร่วม",
    // "ขยายเครือข่ายและความน่าเชื่อถือ",
    // "ไม่ลอง ไม่เสี่ยง ชีวิตปลอดภัย",
    // "สร้างเนื้อหาน่าสนใจและเป็นประโยชน์",
    // "ตรวจสอบและแก้ไขข้อมูลอย่างสุภาพ",
    // "ข้อมูลที่คลาดเคลื่อนและสื่อการตลาด",
    // "คนเข้าใจถึงอันตรายและเลือกที่จะไม่สูบ",
  ];

  late List<String> userAnswers; // Initialize userAnswers based on the number of questions
  int score = 0;
  int currentIndex = 0;
  String characterImage = 'assets/images/buddy_8.png';
  bool answered = false;
  bool isCorrect = false;

  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3',
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3',
  )..preload = 'auto';

  final List<String> questionImages = [
    'assets/images/question1_r3.png', // รูปใหม่สำหรับ Route 3
    // 'assets/images/question2_r3.jpg',
    // 'assets/images/question3_r3.png',
    // 'assets/images/question4_r3.jpg',
    // 'assets/images/question5_r3.jpg',
    // 'assets/images/question6_r3.png',
    // 'assets/images/question7_r3.jpg',
    // 'assets/images/question8_r3.png',
    // 'assets/images/question9_r3.jpg',
    // 'assets/images/question10_r3.png',
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
        chapterToAdvanceTo = 1;
        routeIdToAdvanceTo = widget.routeId + 1;
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