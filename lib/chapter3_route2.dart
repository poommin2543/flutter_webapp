// lib/chapter3_route2.dart - บทที่ 3 สำหรับเส้นทางที่ 2
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'gate_result_page.dart';
import 'constants.dart';

class Chapter3Route2Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId;
  final VoidCallback onFinished;

  Chapter3Route2Page({
    required this.chapter,
    required this.username,
    required this.routeId,
    required this.onFinished,
  });

  @override
  _Chapter3Route2PageState createState() => _Chapter3Route2PageState();
}

class _Chapter3Route2PageState extends State<Chapter3Route2Page> {
  late YoutubePlayerController _controller;
  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3',
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3',
  )..preload = 'auto';

  // เนื้อหาสำหรับเส้นทางที่ 2 บทที่ 3 (แตกต่างจากเส้นทางที่ 1)
  final List<String> videoIds = [
    'OBnA5HF6kvk', // ตัวอย่าง videoId ที่แตกต่าง
    '3xzXJboz1E0',
    'AvcAVT_XQA0',
    'gCahggGt7ao',
    'dfofaZaJ3Rc',
  ];
  final List<String> questions = [
    'ในฐานะเพื่อน เราควรมีบทบาทอย่างไรในการช่วยให้เพื่อนเลิกบุหรี่ไฟฟ้า?',
    'หากเพื่อนปฏิเสธที่จะฟังข้อมูลเรื่องบุหรี่ไฟฟ้า ควรทำอย่างไร?',
    'ข้อใดคือวิธีที่มีประสิทธิภาพในการโน้มน้าวใจเพื่อนให้เข้าใจถึงอันตราย?',
    'เมื่อเพื่อนตัดสินใจจะเลิกบุหรี่ไฟฟ้า เราควรให้การสนับสนุนอย่างไร?',
    'หากเพื่อนกลับไปสูบบุหรี่ไฟฟ้าอีกครั้ง ควรปฏิบัติต่อเพื่อนอย่างไร?',
  ];
  final List<List<String>> options = [
    ['บังคับให้เลิก', 'ให้กำลังใจและสนับสนุน', 'วิพากษ์วิจารณ์', 'ไม่สนใจ'],
    ['เลิกพูดถึงเรื่องนั้น', 'พยายามพูดคุmยและทำความเข้าใจ', 'ตำหนิเพื่อน', 'รายงานครูทันที'],
    ['ใช้คำพูดรุนแรง', 'ให้ข้อมูลทางวิทยาศาสตร์', 'ทำให้เพื่อนรู้สึกผิด', 'เปรียบเทียบกับคนอื่น'],
    ['ปล่อยให้เลิกเอง', 'ให้คำปรึกษาเพิ่มเติม', 'ไม่ให้กำลังใจ', 'ให้รางวัลเมื่อเลิกได้'],
    ['ตำหนิและตัดขาด', 'ให้กำลังใจและชวนคุยถึงสาเหตุ', 'เมินเฉย', 'บอกว่าไม่มีทางเลิกได้'],
  ];
  final List<String> answers = [
    'ให้กำลังใจและสนับสนุน',
    'พยายามพูดคุยและทำความเข้าใจ',
    'ให้ข้อมูลทางวิทยาศาสตร์',
    'ให้คำปรึกษาเพิ่มเติม',
    'ให้กำลังใจและชวนคุยถึงสาเหตุ',
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
                      chapterDescription: 'บททดสอบเกี่ยวกับทักษะการตัดสินใจ',
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
