// lib/chapter1.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'gate_result_page.dart'; // Use the combined GateResultPage
import 'constants.dart'; // For AppConstants.API_BASE_URL
import 'dart:html' as html; // For AudioElement in Flutter Web

class Chapter1Page extends StatefulWidget {
  final int chapter;
  final String username;
  final VoidCallback onFinished;
  final int routeId; // Add this: to specify which route this chapter belongs to

  Chapter1Page({
    required this.chapter,
    required this.username,
    required this.onFinished,
    required this.routeId, // Add this
  });

  @override
  _Chapter1PageState createState() => _Chapter1PageState();
}

class _Chapter1PageState extends State<Chapter1Page> {
  // Questions for Chapter 1
  List<String> questions = [
    "หากน้องๆ ต้องการข้อมูลล่าสุดเกี่ยวกับบุหรี่ไฟฟ้า ควรเลือกค้นหาจาก?",
    "การเข้าถึงข้อมูลแบบไหนในปัจจุบันเกี่ยวกับบุหรี่ไฟฟ้าที่เข้าถึงง่ายที่สุด?",
    "คำค้นหา (Keyword) ใดให้ข้อมูลเฉพาะเจาะจงเกี่ยวกับอันตรายของบุหรี่ไฟฟ้าในวัยรุ่นมากที่สุด?",
    "หากน้องๆ ต้องการรู้ “กฎหมายไทยเกี่ยวกับบุหรี่ไฟฟ้า” คำค้นหาใดเหมาะสมที่สุด?",
    "ถ้าค้นหาด้วยคำว่า “กฎหมายห้ามสูบบุหรี่ไฟฟ้าในโรงเรียน” สิ่งที่น้องๆ คาดว่าจะเจอได้คืออะไร?",
    "ตัวอย่างของ “ข้อมูลจากคนอื่น” ที่ไม่เหมาะกับการใช้ในการตัดสินใจเรื่องบุหรี่ไฟฟ้า คืออะไร?",
    "ในกรณีที่มีข่าวจาก 2 แหล่งข้อมูลให้ข้อมูลไม่ตรงกันเกี่ยวกับอันตรายของบุหรี่ไฟฟ้า น้องๆ จะทำอย่างไร?",
    "หากต้องการเปรียบเทียบข้อมูลจากหลายแหล่งเกี่ยวกับบุหรี่ไฟฟ้า น้องๆ จะทำอย่างไร?",
    "ข้อใดคือวิธีที่ดีที่สุดในการเข้าถึงข้อมูลที่ถูกต้อง?",
    "ข้อมูลเกี่ยวกับบุหรี่ไฟฟ้าที่น่าเชื่อถือได้มากที่สุดมาจากหน่วยงานใด?",
  ];

  // Options for each question
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

  // Correct answers
  List<String> answers = [
    "เว็บไซต์ของหน่วยงานสุขภาพ",
    "สื่อสังคมออนไลน์",
    "อันตรายบุหรี่ไฟฟ้าในวัยรุ่น",
    "กฎหมายบุหรี่ไฟฟ้าในประเทศไทย",
    "ระเบียบของกระทรวงศึกษาธิการ",
    "ความคิดเห็นจากเพื่อนที่เคยลอง", // This might need to be changed to another correct answer if desired
    "ตรวจสอบแหล่งข้อมูลเพิ่มเติมทั้งสองแหล่ง",
    "ค้นจากหลายเว็บไซต์และเปรียบเทียบข้อมูล",
    "ใช้คำค้นที่เจาะจง และตรวจสอบหลายแหล่ง",
    "สำนักงานคณะกรรมการอาหารและยา (อย.)",
  ];

  // Initialize userAnswers based on the number of questions
  late List<String> userAnswers;
  int score = 0; // Score obtained in this chapter
  int currentIndex = 0; // Current question index
  String characterImage =
      'assets/images/buddy_8.png'; // Character image for display
  bool answered = false; // Status whether the question has been answered
  bool isCorrect = false; // Status whether the answer is correct

  // Audio files for Flutter Web
  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3',
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3',
  )..preload = 'auto';

  // Question images (ensure enough images for all questions)
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
    'assets/images/question10.jpg', // Add 10th image if available
  ];

  //late html.AudioElement backgroundAudio;

  final html.AudioElement backgroundAudio =
      html.AudioElement('assets/sounds/background.mp3')
        ..loop = true
        ..autoplay = true
        ..volume = 0.3;

  @override
  void initState() {
    super.initState();

    backgroundAudio.play();
    userAnswers = List.filled(
      questions.length,
      "",
    ); // Initialize userAnswers correctly
  }

  @override
  void dispose() {
    backgroundAudio.pause();
    backgroundAudio.remove(); // optional
    super.dispose();
  }

  // Function to play correct sound
  void playCorrect() {
    if (kIsWeb) {
      correctAudio.pause();
      correctAudio.currentTime = 0;
      correctAudio.play();
    }
  }

  // Function to play wrong sound
  void playWrong() {
    if (kIsWeb) {
      wrongAudio.pause();
      wrongAudio.currentTime = 0;
      wrongAudio.play();
    }
  }

  // Function to submit answer
  void submitAnswer(String selected) async {
    if (answered) return; // Prevent multiple submissions

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

    // Calculate total score for this chapter (only if correct)
    if (correct) {
      score++;
    }

    await Future.delayed(
      const Duration(seconds: 3),
    ); // Wait for 3 seconds for user to see results

    setState(() {
      answered = false;
      characterImage = 'assets/images/buddy_8.png'; // Revert to normal image
    });

    // Check if all questions in the current chapter have been answered.
    // This is the condition for marking the *chapter quiz* as finished.
    bool isCurrentChapterQuizFinished = (currentIndex + 1 >= questions.length);

    // Default values if not finished or moving to next question in same chapter
    int chapterToAdvanceTo = widget.chapter;
    int routeIdToAdvanceTo = widget.routeId;

    if (isCurrentChapterQuizFinished) {
      // If this is the last chapter of a route (e.g., chapter 5)
      // Assuming 5 chapters per route (Chapter 1 to 5)
      if (widget.chapter == 5) {
        chapterToAdvanceTo = 1; // Go back to chapter 1 for the next route
        routeIdToAdvanceTo = widget.routeId + 1; // Advance to the next route
      } else {
        // If it's not the last chapter of a route, just advance to the next chapter in the same route
        chapterToAdvanceTo = widget.chapter + 1;
        routeIdToAdvanceTo = widget.routeId;
      }
    }

    // Send score and progress status to Backend
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'chapter':
              widget.chapter, // The chapter whose quiz was just completed
          'score': score, // Total score obtained in this chapter
          'route_id': widget.routeId, // <--- Send routeId obtained
          'is_finished':
              isCurrentChapterQuizFinished, // <--- Send true if all questions in *this chapter* are done
          'next_chapter':
              chapterToAdvanceTo, // <--- The chapter the user should progress to
          'next_route_id':
              routeIdToAdvanceTo, // <--- The route the user should progress to
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

    // Check if there are more questions in this chapter
    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex++; // Move to the next question
      });
    } else {
      // All questions in this chapter are finished
      print(
        'Chapter ${widget.chapter} (Route ${widget.routeId}) finished. Final score: $score',
      );

      // Show score summary dialog
      if (!mounted)
        return; // Check if Widget is still on the Tree before showing Dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing Dialog by tapping outside
        builder: (context) => AlertDialog(
          title: const Text("คะแนนของคุณ"),
          content: Text("คุณได้ $score จาก ${questions.length} คะแนน"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close Dialog
                // Navigate to GateResultPage to go to the next chapter or route
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GateResultPage(
                      username: widget.username,
                      nextChapter:
                          chapterToAdvanceTo, // Send the calculated next chapter
                      nextRouteId:
                          routeIdToAdvanceTo, // Send the calculated next route
                      message: 'จบบทที่ ${widget.chapter} แล้ว 🎉',
                      chapterDescription:
                          'กำลังเข้าสู่บทต่อไป...', // Can adjust message
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
          'เส้นทางที่ ${widget.routeId} บทที่ ${widget.chapter} – ข้อที่ ${currentIndex + 1}/${questions.length}',
        ),
        automaticallyImplyLeading: false, // Hide back button
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
