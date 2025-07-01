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
    'tBUpITvjBNQ',
    'lfJ1salR9IY',
  ];
  final List<String> questions = [
    'พฤติกรรมของเยาวชนที่หันเข้าหาบุหรี่ไฟฟ้าคืออะไร?',
    'สิ่งที่น่ากังวลในวัยเด็กและเยาวชนจากการสูบบุหรี่ไฟฟ้าคืออะไร?',
    'ข้อเท็จจริงที่ว่าบุหรี่ไฟฟ้าเลิกสูบง่ายกว่าบุหรี่มวนจริงหรือไม่?',
    'ผู้ที่สูบบุหรี่ไฟฟ้าในประเทศไทยส่วนใหญ่จะเป็นวัยใด?',
    'สิ่งที่น้องๆ ควรสื่อสารออกไปคืออะไรเกี่ยวกับบุหรี่ไฟฟ้า?',
  ];
  final List<List<String>> options = [
    ['อยากรู้ อยากลอง', 'ไม่สนใจคำเตือน', 'ขาดความรู้', 'ถูกทุกข้อ'],
    [
      'สมองสูญเสียการพัฒนา',
      'ช่วยให้หายใจโล่ง',
      'ลดความเครียดได้',
      'ใช้แล้วรู้สึกว่าเท่และเป็นที่ยอมรับ',
    ],
    ['ไม่จริง', 'จริง', 'อาจจะใช่', 'ไม่มีข้อมูลที่ชัดเจน'],
    ['เด็กประถม', 'วัยรุ่น', 'ผู้ใหญ่ตอนต้น', 'ผู้สูงอายุ'],
    [
      'สนับสนุนให้ทุกคนได้ลองด้วยตัวเอง',
      'ชี้ให้เห็นถึงอันตรายของบุหรี่ไฟฟ้า',
      'แชร์รีวิวกลิ่นบุหรี่ไฟฟ้าที่หอมที่สุด',
      'ชวนเพื่อนๆ ซื้อและทดลองสูบด้วยกัน',
    ],
  ];
  final List<String> answers = [
    'ถูกทุกข้อ',
    'สมองสูญเสียการพัฒนา',
    'ไม่จริง',
    'วัยรุ่น',
    'ชี้ให้เห็นถึงอันตรายของบุหรี่ไฟฟ้า',
  ];

  int currentIndex = 0;
  late List<String> userAnswers;
  int totalScore = 0;
  bool answered = false;
  bool isCorrect = false;
  String characterImage = 'assets/images/buddy_8.png';
  bool videoEnded = false; // add this to your state

  final html.AudioElement backgroundAudio =
      html.AudioElement('assets/sounds/background.mp3')
        ..loop = true
        ..autoplay = true
        ..volume = 0.3;

  @override
  void initState() {
    super.initState();
    backgroundAudio.play();
    userAnswers = List.filled(videoIds.length, '');
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoIds[0],
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
      ),
    );

    _controller.listen((event) {
      if (event.playerState == PlayerState.ended) {
        setState(() {
          videoEnded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    backgroundAudio.pause();
    backgroundAudio.src = '';
    _controller.close();
    super.dispose();
  }

  void _loadVideoAtIndex(int idx) {
    _controller.loadVideoById(videoId: videoIds[idx]);
    setState(() {
      answered = false;
      videoEnded = false; // reset flag
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
        ? 'assets/images/buddy_8c.gif'
        : 'assets/images/buddy_8w.gif';

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
        print(
          'Failed to submit score: ${response.statusCode} - ${response.body}',
        );
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
      print(
        'Chapter ${widget.chapter} (Route ${widget.routeId}) finished. Final score: $totalScore',
      );

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(characterImage, height: 400),
                const SizedBox(width: 20),
                SizedBox(
                  width: 700,
                  height: 400,
                  child: YoutubePlayer(controller: _controller),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              questions[currentIndex],
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ...options[currentIndex]
                .map(
                  (opt) => SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: RadioListTile<String>(
                        title: Text(
                          opt,
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        value: opt,
                        groupValue: userAnswers[currentIndex],
                        onChanged: (!answered && videoEnded)
                            ? (val) => setState(
                                () => userAnswers[currentIndex] = val!,
                              )
                            : null,
                        tileColor: _optionColor(opt),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
            if (answered) const SizedBox(height: 10),
            if (answered)
              Text(
                isCorrect ? 'ตอบถูกต้อง 🎉' : 'ผิด ไม่เป็นไรนะ 😟',
                style: TextStyle(
                  fontSize: 18,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  (!videoEnded || answered || userAnswers[currentIndex].isEmpty)
                  ? null
                  : _submitAnswer,
              child: Text(
                answered
                    ? (currentIndex + 1 < videoIds.length ? 'ถัดไป' : 'ส่ง')
                    : 'ยืนยัน',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
