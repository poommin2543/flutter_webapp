// lib/chapter3_route3.dart - บทที่ 3 สำหรับเส้นทางที่ 3
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'gate_result_page.dart';
import 'constants.dart';

class Chapter3Route3Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId;
  final VoidCallback onFinished;

  Chapter3Route3Page({
    required this.chapter,
    required this.username,
    required this.routeId,
    required this.onFinished,
  });

  @override
  _Chapter3Route3PageState createState() => _Chapter3Route3PageState();
}

class _Chapter3Route3PageState extends State<Chapter3Route3Page> {
  late YoutubePlayerController _controller;
  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3',
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3',
  )..preload = 'auto';

  // เนื้อหาสำหรับเส้นทางที่ 3 บทที่ 3 (แตกต่างจากเส้นทางที่ 1 และ 2)
  final List<String> videoIds = [
    '3xzXJboz1E0', // ตัวอย่าง videoId ที่แตกต่าง
    // 'AvcAVT_XQA0',
    // 'gCahggGt7ao',
    // 'dfofaZaJ3Rc',
    // 'OBnA5HF6kvk',
  ];
  final List<String> questions = [
    'ในวิดีโอนี้ ผู้นำที่ต้องการสร้างการเปลี่ยนแปลงควรเน้นคุณสมบัติใด?',
    // 'การจัดกิจกรรมรณรงค์ในโรงเรียนควรมีส่วนร่วมจากใครบ้างเพื่อความสำเร็จ?',
    // 'การใช้สื่อสังคมออนไลน์ในการสร้างการรับรู้ควรเน้นอะไรเพื่อให้เข้าถึงเยาวชน?',
    // 'หากพบกลุ่มเพื่อนที่ยังคงสูบบุหรี่ไฟฟ้าในโรงเรียน คุณจะจัดการสถานการณ์นี้อย่างไร?',
    // 'ข้อใดคือวิธีการประเมินผลความสำเร็จของกิจกรรมรณรงค์ได้อย่างเหมาะสม?',
  ];
  final List<List<String>> options = [
    ['ความสามารถในการพูดคนเดียว', 'ความสามารถในการสร้างแรงบันดาลใจและร่วมมือ', 'ความแข็งกร้าว', 'ความเงียบเฉย'],
    // ['แค่ครู', 'แค่นักเรียน', 'นักเรียน ครู ผู้บริหาร และผู้ปกครอง', 'แค่อาสาสมัคร'],
    // ['เนื้อหาหนักๆ', 'เนื้อหาสร้างสรรค์ สั้น กระชับ และตรงประเด็น', 'การใช้คำพูดเชิงลบ', 'การโพสต์รูปน่ากลัว'],
    // ['ไม่สนใจ', 'เข้าไปเตือนอย่างรุนแรง', 'หาโอกาสพูดคุยให้ข้อมูลอย่างเป็นส่วนตัว', 'รายงานครูทันที'],
    // ['ดูจำนวนคนที่เข้าร่วม', 'ประเมินจากการเปลี่ยนแปลงทัศนคติและพฤติกรรม', 'ดูจากเสียงปรบมือ', 'ดูจากจำนวนรูปถ่าย'],
  ];
  final List<String> answers = [
    'ความสามารถในการสร้างแรงบันดาลใจและร่วมมือ',
    // 'นักเรียน ครู ผู้บริหาร และผู้ปกครอง',
    // 'เนื้อหาสร้างสรรค์ สั้น กระชับ และตรงประเด็น',
    // 'หาโอกาสพูดคุยให้ข้อมูลอย่างเป็นส่วนตัว',
    // 'ประเมินจากการเปลี่ยนแปลงทัศนคติและพฤติกรรม',
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
    if (!mounted) return;

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
        chapterToAdvanceTo = 1;
        routeIdToAdvanceTo = widget.routeId + 1;
      } else {
        // หากไม่ใช่บทที่ 5 ให้เลื่อนไปบทถัดไปในเส้นทางเดิม
        chapterToAdvanceTo = widget.chapter + 1;
        routeIdToAdvanceTo = widget.routeId;
      }
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
                      chapterDescription: 'กำลังเข้าสู่บทต่อไป...',
                      message: 'จบบทที่ ${widget.chapter} เส้นทางที่ ${widget.routeId} แล้ว 🎉',
                      nextChapter: chapterToAdvanceTo,
                      nextRouteId: routeIdToAdvanceTo,
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