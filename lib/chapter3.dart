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
    'AvcAVT_XQA0',
    'OBnA5HF6kvk',
    '3xzXJboz1E0',
    'WwSfLUtrx_Y', // วิดีโอซ้ำในโจทย์เดิม อาจจะแทนด้วยรูปภาพ
    'WwSfLUtrx_Y', // วิดีโอซ้ำในโจทย์เดิม อาจจะแทนด้วยรูปภาพ
  ];
  final List<String> questions = [
    'พฤติกรรมของเยาวชนที่หันเข้าหาบุหรี่ไฟฟ้าคืออะไร?',
    'สิ่งที่น่ากังวลในวัยเด็กและเยาวชนจากการสูบบุหรี่ไฟฟ้าคืออะไร?',
    'ข้อเท็จจริงที่ว่าบุหรี่ไฟฟ้าเลิกสูบง่ายกว่าบุหรี่มวนจริงหรือไม่?',
    'กลิ่นหอมจากบุหรี่ไฟฟ้าไม่ส่งผลอันตรายต่อร่างกาย?',
    'โรคที่มักเกิดจากบุหรี่ไฟฟ้าได้แก่?',
  ];
  final List<List<String>> options = [
    ['อยากรู้ อยากลอง', 'ไม่สนใจคำเตือน', 'ขาดความรู้', 'ถูกทุกข้อ'],
    [
      'สมองสูญเสียการพัฒนา',
      'ช่วยให้หายใจโล่ง',
      'ลดความเครียดได้',
      'ใช้แล้วรู้สึกว่าเท่และเป็นที่ยอมรับ',
    ],
    ['ไม่จริง ', 'จริง', 'อาจจะใช่', 'ไม่มีข้อมูลที่ชัดเจน'],
    [
      'จริงทั้งหมด',
      'จริง ขึ้นอยู่กับกลิ่นและรสชาติ',
      'ไม่จริง ขึ้นอยู่กับกลิ่นและรสชาติ',
      'ไม่จริงทั้งหมด',
    ],
    ['POV', 'CANCER', 'EVALI', 'COVID'],
  ];
  final List<String> answers = [
    'ถูกทุกข้อ',
    'สมองสูญเสียการพัฒนา',
    'ไม่จริง', // แก้ไขตามคำตอบที่ถูกต้องใน backend
    'ไม่จริงทั้งหมด',
    'EVALI',
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
    if (idx < videoIds.length && idx < 3) { // สำหรับวิดีโอ 3 ตัวแรก
      _controller.loadVideoById(videoId: videoIds[idx]);
    }
    setState(() {
      answered = false;
      userAnswers[idx] = '';
      characterImage = 'assets/images/buddy_8.png';
    });
  }

  Future<void> _submitAnswer() async {
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
    if (!mounted) return;

    if (isCorrect) {
      totalScore++;
    }

    if (currentIndex + 1 < videoIds.length) {
      currentIndex++;
      _loadVideoAtIndex(currentIndex);
    } else {
      // เมื่อจบบทเรียน
      await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'route_id': widget.routeId, // ส่ง route_id
          'chapter_number': widget.chapter,
          'score': totalScore,
        }),
      );
      await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/update_progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'current_chapter': widget.chapter + 1,
          'current_route_id': widget.routeId, // ส่ง routeId ปัจจุบัน
        }),
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("คะแนนของคุณ"),
          content: Text("คุณได้ $totalScore จาก ${answers.length} ข้อ"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GateResultPage(
                      chapterDescription: 'บททดสอบเกี่ยวกับการตัดสินใจ',
                      message: 'จบบทที่ ${widget.chapter} แล้ว 🎉',
                      nextChapter: widget.chapter + 1,
                      nextRouteId: widget.routeId, // ส่ง routeId ปัจจุบัน
                      username: widget.username,
                    ),
                  ),
                );
              },
              child: const Text('OK'),
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
          'บทที่ ${widget.chapter} – ข้อที่ ${currentIndex + 1}/${videoIds.length}',
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
              child: currentIndex == 3
                  ? Image.asset('assets/images/Q34.jpg', fit: BoxFit.contain)
                  : currentIndex == 4
                      ? Image.asset('assets/images/Q35.jpg', fit: BoxFit.contain)
                      : YoutubePlayer(controller: _controller),
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
                            setState(() => userAnswers[currentIndex] = val!),
                ),
              ),
            ).toList(), // เพิ่ม .toList()
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
