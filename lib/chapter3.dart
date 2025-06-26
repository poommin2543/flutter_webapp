import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'chapter4.dart';
import 'dart:html' as html;
import 'gate_result_page3.dart'; // นำเข้า GateResultPage ที่ถูกต้อง

class Chapter3Page extends StatefulWidget {
  final int chapter;
  final String username;
  final VoidCallback onFinished;

  Chapter3Page({
    required this.chapter,
    required this.username,
    required this.onFinished,
  });

  @override
  _Chapter3PageState createState() => _Chapter3PageState();
}

class _Chapter3PageState extends State<Chapter3Page> {
  late YoutubePlayerController _controller;
  final html.AudioElement correctAudio = html.AudioElement(
    //'assets/sounds/correct.mp3',
    'assets/sounds/wrong.mp3',
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    //'assets/sounds/wrong.mp3',
    'assets/sounds/correct.mp3',
  )..preload = 'auto';

  final List<String> videoIds = [
    'AvcAVT_XQA0',
    'OBnA5HF6kvk',
    '3xzXJboz1E0',
    'WwSfLUtrx_Y',
    'WwSfLUtrx_Y',
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
    'จริง',
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
      params: YoutubePlayerParams(
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

    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;

    if (isCorrect) {
      totalScore++;
    }

    if (currentIndex + 1 < videoIds.length) {
      currentIndex++;
      _loadVideoAtIndex(currentIndex);
    } else {
      await http.post(
        Uri.parse('https://apiwebmoss.roverautonomous.com/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'chapter_number': widget.chapter,
          'score': totalScore,
        }),
      );
      await http.post(
        Uri.parse('https://apiwebmoss.roverautonomous.com/update_progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'current_chapter': widget.chapter + 1,
        }),
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("คะแนนของคุณ"),
          content: Text("คุณได้ $totalScore จาก ${answers.length} ข้อ"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GateResultPage(chapter: 4, username: widget.username),
                  ),
                );
              },
              child: Text('OK'),
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
        padding: EdgeInsets.all(16),
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
            SizedBox(height: 20),
            Text(
              questions[currentIndex],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            ),
            if (answered) SizedBox(height: 10),
            if (answered)
              Text(
                isCorrect ? 'ตอบถูกต้อง 🎉' : 'ผิด ลองใหม่ 😟',
                style: TextStyle(
                  fontSize: 18,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  (!answered && userAnswers[currentIndex].isNotEmpty) ||
                      answered
                  ? _submitAnswer
                  : null,
              child: Text(
                answered
                    ? (currentIndex + 1 < videoIds.length ? 'ถัดไป' : 'ส่ง')
                    : 'ยืนยัน',
              ),
            ),
            SizedBox(height: 20),
            Image.asset(characterImage, height: 120),
          ],
        ),
      ),
    );
  }
}
