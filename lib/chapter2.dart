// lib/chapter2.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html; // สำหรับ AudioElement
import 'gate_result_page.dart'; // นำเข้า GateResultPage ที่รวม
import 'constants.dart'; // นำเข้า AppConstants

class Chapter2Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId; // เพิ่ม: รับ routeId เข้ามา
  final VoidCallback onFinished;

  Chapter2Page({
    required this.chapter,
    required this.username,
    required this.routeId, // กำหนดให้รับ routeId
    required this.onFinished,
  });

  @override
  _Chapter2PageState createState() => _Chapter2PageState();
}

class _Chapter2PageState extends State<Chapter2Page> {
  late YoutubePlayerController _controller;
  // สำหรับ Web, path ของ Audio ต้องสัมพันธ์กับ web/index.html
  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3', // ตรวจสอบว่ามีไฟล์นี้ใน web/assets/sounds
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3', // ตรวจสอบว่ามีไฟล์นี้ใน web/assets/sounds
  )..preload = 'auto';

  final List<String> videoIds = [
    '_8XW_BgiD_Q', // ตัวอย่าง videoId
    'dfofaZaJ3Rc',
    'gCahggGt7ao',
    'WwSfLUtrx_Y',
    'WwSfLUtrx_Y', // วิดีโอซ้ำในโจทย์เดิม อาจจะแทนด้วยรูปภาพ
  ];
  final List<String> questions = [
    'บุหรี่ไฟฟ้ามีสิ่งใดที่สามารถชักจูงให้เยาวชนสนใจ?',
    'สาเหตุที่เยาวชนเริ่มสูบบุหรี่ไฟฟ้าได้แก่อะไร?',
    'อันตรายจากสารพิษในบุหรี่ไฟฟ้าส่งผลกระทบต่อส่วนใดของร่างกาย?',
    'บุหรี่ไฟฟ้าผิดกฏหมายในประเทศไทยหรือไม่?',
    'ข้อใดคือความเข้าใจผิดเกี่ยวกับบุหรี่ไฟฟ้า?',
  ];
  final List<List<String>> options = [
    ['กลิ่นหอม รูปลักษณ์', 'มีสารเสพติด', 'ปลอดภัยกว่าบุหรี่มวน', 'มีความเท่ห์'],
    ['มีความอันตรายน้อย', 'สื่อชักชวน', 'ควันมือสอง', 'เพื่อนชักชวน'],
    ['ไต', 'อวัยวะทุกส่วนในร่างกาย', 'หัวใจ', 'ข้อกระดูก'],
    [
      'ถูกกฏหมาย',
      'ผิดกฏหมายเฉพาะผู้นำเข้า',
      'ผิดกฏหมายเฉพาะผู้ขาย',
      'ผิดกฏหมายทั้งหมดไม่ว่ากรณีใดก็ตาม',
    ],
    ['ขาดความตระหนัก', 'ความเชื่อที่ผิด', 'ไม่มีสารนิโคติน', 'ถูกทุกข้อ'],
  ];
  final List<String> answers = [
    'กลิ่นหอม รูปลักษณ์',
    'เพื่อนชักชวน',
    'อวัยวะทุกส่วนในร่างกาย',
    'ผิดกฏหมายทั้งหมดไม่ว่ากรณีใดก็ตาม',
    'ถูกทุกข้อ',
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
    // โหลดวิดีโอถ้าไม่ใช่ index 4 (ซึ่งใช้รูปภาพแทน)
    if (idx < videoIds.length && idx != 4) {
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
      print('Chapter ${widget.chapter} (Route ${widget.routeId}) finished. Final score: $totalScore');

      // กำหนดค่าสำหรับส่งไป Backend
      bool isFinishedChapter = (widget.chapter == 5); // ถ้าเป็นบทที่ 5 คือจบบทเรียนในเส้นทางนั้น
      int nextChapterToSend = widget.chapter + 1; // บทถัดไป (อาจเป็น 6 ถ้าจบบท 5)
      int nextRouteIDToSend = widget.routeId;     // เส้นทางยังคงเดิม

      // ถ้าจบบทที่ 5 แล้ว (isFinishedChapter = true)
      // ให้ nextChapterToSend เป็น 6 และ nextRouteIDToSend เป็น 1
      if (isFinishedChapter) {
        nextChapterToSend = 6;
        nextRouteIDToSend = 1;
      }

      try {
        final response = await http.post(
          Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': widget.username,
            'chapter': widget.chapter,
            'score': totalScore,
            'route_id': widget.routeId,
            'is_finished': isFinishedChapter,
            'next_chapter': nextChapterToSend,
            'next_route_id': nextRouteIDToSend,
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

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
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
                      chapterDescription: 'บททดสอบเกี่ยวกับความสามารถในการสื่อสารและประเมินข้อมูล',
                      message: 'จบบทที่ ${widget.chapter} แล้ว 🎉',
                      nextChapter: nextChapterToSend,
                      nextRouteId: nextRouteIDToSend,
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
              child: currentIndex == 4
                  ? Image.asset('assets/images/Q5.jpg', fit: BoxFit.contain)
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
