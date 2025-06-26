// lib/chapter2_route3.dart - บทที่ 2 สำหรับเส้นทางที่ 3
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'gate_result_page.dart';
import 'constants.dart';

class Chapter2Route3Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId;
  final VoidCallback onFinished;

  Chapter2Route3Page({
    required this.chapter,
    required this.username,
    required this.routeId,
    required this.onFinished,
  });

  @override
  _Chapter2Route3PageState createState() => _Chapter2Route3PageState();
}

class _Chapter2Route3PageState extends State<Chapter2Route3Page> {
  late YoutubePlayerController _controller;
  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3',
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3',
  )..preload = 'auto';

  // เนื้อหาสำหรับเส้นทางที่ 3 บทที่ 2 (แตกต่างจากเส้นทางที่ 1 และ 2)
  final List<String> videoIds = [
    'dfofaZaJ3Rc', // ตัวอย่าง videoId ที่แตกต่าง
    'AvcAVT_XQA0',
    'OBnA5HF6kvk',
    '3xzXJboz1E0',
    '_8XW_BgiD_Q',
  ];
  final List<String> questions = [
    'ในวิดีโอนี้ แนวคิดใดที่ช่วยสร้างแรงบันดาลใจให้ผู้อื่นเลิกบุหรี่ไฟฟ้า?',
    'คุณคิดว่าการเป็นแบบอย่างที่ดีมีผลต่อการเปลี่ยนแปลงพฤติกรรมของคนรอบข้างอย่างไร?',
    'หากคุณต้องการรณรงค์ให้เพื่อนในโรงเรียนเลิกบุหรี่ไฟฟ้า จะเริ่มต้นอย่างไร?',
    'การใช้เรื่องราวส่วนตัวในการรณรงค์มีประโยชน์อย่างไร?',
    'ข้อใดคือทักษะสำคัญที่ผู้นำการเปลี่ยนแปลงควรมี?',
  ];
  final List<List<String>> options = [
    ['การบังคับ', 'การให้ข้อมูลด้านลบ', 'การสร้างความหวังและการสนับสนุน', 'การตำหนิ'],
    ['ไม่มีผล', 'มีผลน้อยมาก', 'มีผลอย่างมากในการกระตุ้นและสร้างความน่าเชื่อถือ', 'ทำให้คนรำคาญ'],
    ['ติดโปสเตอร์อย่างเดียว', 'จัดกิจกรรมที่น่าสนใจและให้ความรู้', 'พูดคุยกับเพื่อนทีละคน', 'แจ้งครูใหญ่'],
    ['ทำให้คนสงสัย', 'สร้างความรู้สึกร่วมและเข้าใจง่าย', 'ทำให้เรื่องดูน่าเบื่อ', 'ไม่มีประโยชน์'],
    ['ความสามารถในการโต้เถียง', 'ความเห็นอกเห็นใจและความมุ่งมั่น', 'ความเฉยเมย', 'ความหยิ่งผยอง'],
  ];
  final List<String> answers = [
    'การสร้างความหวังและการสนับสนุน',
    'มีผลอย่างมากในการกระตุ้นและสร้างความน่าเชื่อถือ',
    'จัดกิจกรรมที่น่าสนใจและให้ความรู้',
    'สร้างความรู้สึกร่วมและเข้าใจง่าย',
    'ความเห็นอกเห็นใจและความมุ่งมั่น',
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
      await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'route_id': widget.routeId,
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
          'current_route_id': widget.routeId,
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
                      chapterDescription: 'บททดสอบเกี่ยวกับการสร้างแรงบันดาลใจและเป็นแบบอย่าง',
                      message: 'จบบทที่ ${widget.chapter} เส้นทางที่ ${widget.routeId} แล้ว 🎉',
                      nextChapter: widget.chapter + 1,
                      nextRouteId: widget.routeId,
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
          'เส้นทางที่ ${widget.routeId} - บทที่ ${widget.chapter} – ข้อที่ ${currentIndex + 1}/${videoIds.length}',
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
                            setState(() => userAnswers[currentIndex] = val!),
                ),
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
