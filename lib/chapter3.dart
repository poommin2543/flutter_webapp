// lib/chapter3.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html; // สำหรับ AudioElement
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่รวม
import 'constants.dart'; // นำเข้า AppConstants

class Chapter3Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId; // เพิ่ม: รับ routeId เข้ามา
  final VoidCallback onFinished;

  Chapter3Page({
    required this.chapter,
    required this.username,
    required this.routeId, // กำหนดให้รับ routeId
    required this.onFinished,
  });

  @override
  _Chapter3PageState createState() => _Chapter3PageState();
}

class _Chapter3PageState extends State<Chapter3Page> {
  late YoutubePlayerController _controller;
  // สำหรับ Web, path ของ Audio ต้องสัมพันธ์กับ web/index.html
  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3', // ตรวจสอบว่ามีไฟล์นี้ใน web/assets/sounds
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3', // ตรวจสอบว่ามีไฟล์นี้ใน web/assets/sounds
  )..preload = 'auto';

  final List<String> videoIds = [
    'gCahggGt7ao', // ตรวจสอบ ID วิดีโอให้ถูกต้อง
    // 'dfofaZaJ3Rc',
    // 'OBnA5HF6kvk',
    // '_8XW_BgiD_Q',
    // '3xzXJboz1E0',
  ];
  final List<String> questions = [
    'ทำไมการตั้งเป้าหมายที่ชัดเจนจึงสำคัญในการเลิกบุหรี่ไฟฟ้า?',
    // 'สิ่งใดที่สามารถช่วยลดความอยากนิโคตินได้?',
    // 'หากคุณรู้สึกอยากกลับไปสูบบุหรี่ไฟฟ้า ควรทำอย่างไร?',
    // 'การสนับสนุนจากเพื่อนและครอบครัวมีผลต่อการเลิกบุหรี่ไฟฟ้าอย่างไร?',
    // 'ข้อใดคือประโยชน์ระยะยาวของการเลิกบุหรี่ไฟฟ้า?',
  ];
  final List<List<String>> options = [
    ['เพื่อให้มีแรงจูงใจ', 'ไม่มีความสำคัญ', 'ทำให้เครียด', 'ทำให้ต้องพยายามมากขึ้น'],
    // ['ดื่มกาแฟ', 'ออกกำลังกาย', 'นอนหลับเยอะๆ', 'รับประทานอาหารรสจัด'],
    // ['ซื้อมาสูบแก้เครียด', 'ปรึกษาผู้เชี่ยวชาญ', 'ไม่สนใจ', 'เก็บไว้คนเดียว'],
    // ['ไม่มีผลเลย', 'ทำให้รู้สึกกดดัน', 'ช่วยให้มีกำลังใจและทำได้สำเร็จมากขึ้น', 'ทำให้รู้สึกอึดอัด'],
    // ['ประหยัดเงิน', 'สุขภาพดีขึ้น', 'ความสัมพันธ์กับคนรอบข้างดีขึ้น', 'ถูกทุกข้อ'],
  ];
  final List<String> answers = [
    'เพื่อให้มีแรงจูงใจ',
    // 'ออกกำลังกาย',
    // 'ปรึกษาผู้เชี่ยวชาญ',
    // 'ช่วยให้มีกำลังใจและทำได้สำเร็จมากขึ้น',
    // 'ถูกทุกข้อ',
  ];

  int currentIndex = 0;
  late List<String> userAnswers;
  int totalScore = 0;
  bool answered = false;
  bool isCorrect = false;
  String characterImage = 'assets/images/buddy_8.png';

  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(videoIds.length, '');
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoIds[0],
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _loadVideoAtIndex(int idx) {
    _controller.loadVideoById(videoId: videoIds[idx]);
    setState(() {
      answered = false;
      userAnswers[idx] = '';
      characterImage = 'assets/images/buddy_8.png';
    });
  }

  Future<void> _submitAnswer() async {
    // ป้องกันการส่งคำตอบซ้ำ
    if (answered) return;

    isCorrect = userAnswers[currentIndex] == answers[currentIndex];
    answered = true;
    characterImage = isCorrect
        ? 'assets/images/buddy_happy.png'
        : 'assets/images/buddy_sad.png';

    if (kIsWeb) {
      if (isCorrect) {
        correctAudio.currentTime = 0;
        correctAudio.play();
      } else {
        wrongAudio.currentTime = 0;
        wrongAudio.play();
      }
    }

    setState(() {});

    await Future.delayed(const Duration(seconds: 2));

    if (isCorrect) {
      totalScore++;
    }

    // ตรวจสอบว่าคำถามทั้งหมดในบทเรียนปัจจุบันถูกตอบแล้วหรือไม่
    bool isCurrentChapterQuizFinished = (currentIndex + 1 >= videoIds.length);
    int chapterToAdvanceTo = widget.chapter;
    int routeIdToAdvanceTo = widget.routeId;

    if (isCurrentChapterQuizFinished) {
      // หากคำถามทั้งหมดในบทเรียนปัจจุบันถูกตอบแล้ว
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
          'score': totalScore,
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

    if (currentIndex + 1 < videoIds.length) {
      setState(() {
        currentIndex++;
        _loadVideoAtIndex(currentIndex);
      });
    } else {
      print('Chapter ${widget.chapter} (Route ${widget.routeId}) finished. Final score: $totalScore');

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("คะแนนของคุณ"),
          content: Text("คุณได้ $totalScore จาก ${answers.length} ข้อ"),
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
                      message: 'จบบทที่ ${widget.chapter} แล้ว 🎉',
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

  Color _optionColor(String opt) {
    if (!answered) return Colors.transparent;
    if (opt == answers[currentIndex]) return Colors.green.withOpacity(0.3);
    if (opt == userAnswers[currentIndex] && !isCorrect)
      return Colors.red.withOpacity(0.3);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เส้นทางที่ ${widget.routeId} บทที่ ${widget.chapter} – ข้อที่ ${currentIndex + 1}/${videoIds.length}',
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 400,
              child: YoutubePlayer(controller: _controller),
            ),
            const SizedBox(height: 20),
            Text(
              questions[currentIndex],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ...options[currentIndex].map(
              (opt) => Container(
                color: _optionColor(opt),
                child: RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: userAnswers[currentIndex],
                  onChanged: answered
                      ? null
                      : (val) =>
                            setState(() => userAnswers[currentIndex] = val!)),
              ),
            ).toList(),
            if (answered) const SizedBox(height: 10),
            if (answered)
              Text(
                isCorrect ? 'ตอบถูกต้อง 🎉' : 'ผิด ลองใหม่ 😟',
                style: TextStyle(
                  fontSize: 18,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  (!answered && userAnswers[currentIndex].isNotEmpty) || answered
                      ? _submitAnswer
                      : null,
              child: Text(
                answered
                    ? (currentIndex + 1 < videoIds.length ? 'ถัดไป' : 'ส่ง')
                    : 'ยืนยัน',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(characterImage, height: 120),
          ],
        ),
      ),
    );
  }
}