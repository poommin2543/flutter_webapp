// lib/chapter2_route2.dart - บทที่ 2 สำหรับเส้นทางที่ 2
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'gate_result_page.dart';
import 'constants.dart';

class Chapter2Route2Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId;
  final VoidCallback onFinished;

  Chapter2Route2Page({
    required this.chapter,
    required this.username,
    required this.routeId,
    required this.onFinished,
  });

  @override
  _Chapter2Route2PageState createState() => _Chapter2Route2PageState();
}

class _Chapter2Route2PageState extends State<Chapter2Route2Page> {
  late YoutubePlayerController _controller;
  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3',
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3',
  )..preload = 'auto';

  // เนื้อหาสำหรับเส้นทางที่ 2 บทที่ 2 (แตกต่างจากเส้นทางที่ 1)
  final List<String> videoIds = [
    '0XJgdVLRjCM', // ตัวอย่าง videoId ที่แตกต่าง
    'mVJjCOdWRpQ',
    'LYtVjGi71no',
    //'8mFCedAbsnQ',
    //'c0Yh0qMjw0Y',
    'gCahggGt7ao', // ตัวอย่าง videoId ที่แตกต่าง
    'dfofaZaJ3Rc',
    '_8XW_BgiD_Q',
    //'3xzXJboz1E0',
    //'AvcAVT_XQA0',
  ];
  final List<String> questions = [
    'ข้อใด "ไม่ใช่" ผลเสียของการใช้บุหรี่ไฟฟ้า?',
    'บุหรี่ไฟฟ้าอาจทำลายสมองส่วนใดในวัยรุ่น?',
    'เมื่อเข้าใจว่าใช้บุหรี่ไฟฟ้าแล้วหายใจลำบาก หมายถึงร่างกายมีปัญหากับ?',
    //'การเข้าใจว่า “บุหรี่ไฟฟ้ามีกลิ่นหอมจึงไม่อันตราย” เป็นความเข้าใจที่?',
    //'บุหรี่ไฟฟ้าอาจก่อให้เกิดโรคใดต่อไปนี้มากที่สุด?',
    'ข้อใดเป็นเหตุผลทางสุขภาพที่ควรเลี่ยงบุหรี่ไฟฟ้า?',
    'เด็กที่เข้าใจโทษของบุหรี่ไฟฟ้าอย่างถูกต้องมีแนวโน้มจะ?',
    'เข้าใจว่า “กลิ่นหอมของบุหรี่ไฟฟ้า” แสดงถึงอะไร?',
    //'การเข้าใจว่า “ใครๆ ก็ใช้” หมายถึงว่าเรากำลังถูกครอบงำด้วย?',
    //'เข้าใจว่า “การทดลองเพียงครั้งเดียวอาจนำไปสู่การเสพติด” ช่วยให้?',
  ];
  final List<List<String>> options = [
    [
      'ทำให้ร่างกายเสพติด',
      'ทำให้รู้สึกสดชื่น',
      'ทำให้ปอดอักเสบ ',
      'ทำให้หายใจลำบาก',
    ],
    ['ความจำ', 'การเคลื่อนไหว', 'การนอนหลับ ', 'อารมณ์ขัน'],
    ['ระบบประสาท', 'ระบบขับถ่าย', 'ระบบทางเดินหายใจ', 'ระบบย่อยอาหาร'],
    //['ถูกต้อง', 'คลุมเครือ', 'ผิดพลาด', 'ไม่มีผล'],
    //['โรคหัวใจ', 'โรคปอดอักเสบ', 'โรคเบาหวาน', 'โรคผิวหนัง'],
    ['มีรสหวาน', 'มีราคาแพง', 'ส่งผลต่อปอด', 'พ่อแม่ไม่อนุญาต'],
    ['สนใจลองมากขึ้น', 'หลีกเลี่ยงการใช้', 'ชวนเพื่อนลอง', 'อยากรู้รสชาติ'],
    ['อันตรายน้อย', 'น่าลอง', 'กลยุทธ์ทางการตลาด', 'สารเพิ่มพลัง'],
    //['ความจริง', 'อารมณ์', 'กลุ่มเพื่อน', 'ค่านิยมผิด'],
    //[
    //  'เพิ่มโอกาสลอง',
    //  'ลดความกังวล',
    //  'ป้องกันตนเองจากการเสพติด',
    //  'หาข้อมูลเพิ่ม',
    //],
  ];
  final List<String> answers = [
    'ทำให้รู้สึกสดชื่น',
    'ความจำ',
    'ระบบทางเดินหายใจ',
    //'ผิดพลาด',
    //'โรคปอดอักเสบ',
    'ส่งผลต่อปอด',
    'หลีกเลี่ยงการใช้',
    'กลยุทธ์ทางการตลาด',
    //'ค่านิยมผิด',
    //'ป้องกันตนเองจากการเสพติด',
  ];

  int currentIndex = 0;
  late List<String> userAnswers;
  int totalScore = 0;
  bool answered = false;
  bool isCorrect = false;
  String characterImage = 'assets/images/buddy_8g.gif';
  bool videoEnded = false;
  bool isSubmitting = false;

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
        showFullscreenButton: false,
        showControls: false,
      ),
    );
    _controller.listen((event) {
      if (event.playerState == PlayerState.ended) {
        setState(() {
          videoEnded = true;
          backgroundAudio.volume = 0.3; // 🔊 เพิ่มเสียงกลับ
        });
      } else if (event.playerState == PlayerState.playing) {
        backgroundAudio.volume = 0.05; // 🔇 ลดเสียงขณะเล่นวิดีโอ
      }
    });
  }

  @override
  void dispose() {
    _controller.close();
    backgroundAudio.pause();
    backgroundAudio.src = '';
    super.dispose();
  }

  void _loadVideoAtIndex(int idx) {
    if (idx < videoIds.length) {
      //if (idx <= 4) {
      if (idx <= 2) {
        _controller.loadVideoById(videoId: videoIds[idx]);
        videoEnded = false;
      } else {
        // ไม่โหลดวิดีโอถ้า index > 4
        videoEnded = true;
      }
    }
    setState(() {
      answered = false;
      userAnswers[idx] = '';
      characterImage = 'assets/images/buddy_8.png';
    });
  }

  Future<void> _submitAnswer() async {
    // ป้องกันการส่งคำตอบซ้ำ
    if (answered || isSubmitting) return; // ป้องกันกดซ้ำ

    setState(() => isSubmitting = true);

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
        isSubmitting = false; // ✅ เปิดปุ่มอีกครั้งหลังโหลดคำถามใหม่
      });
    } else {
      print(
        'Chapter ${widget.chapter} (Route ${widget.routeId}) finished. Final score: $totalScore',
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
                      chapterDescription:
                          'กำลังเข้าสู่บทต่อไป...', // ปรับคำอธิบาย
                      message:
                          'จบบทที่ ${widget.chapter} เส้นทางที่ ${widget.routeId} แล้ว 🎉',
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
          'เส้นทางที่ ${widget.routeId} บทที่ ${widget.chapter} – ข้อที่ ${currentIndex + 1}/${videoIds.length}',
        ),
        automaticallyImplyLeading: false, // ซ่อนปุ่มย้อนกลับ
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
                //if (currentIndex <= 4)
                if (currentIndex <= 2)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 400,
                    child: YoutubePlayer(controller: _controller),
                  ),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              questions[currentIndex],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (!videoEnded && currentIndex <= 4)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'กรุณาชมวิดีโอให้จบก่อนเลือกคำตอบ',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            // Option cards
            ...options[currentIndex]
                .map(
                  (opt) => Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: RadioListTile<String>(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        title: Text(opt, textAlign: TextAlign.center),
                        value: opt,
                        groupValue: userAnswers[currentIndex],
                        onChanged: (!answered && videoEnded)
                            ? (val) {
                                setState(
                                  () => userAnswers[currentIndex] = val!,
                                );
                              }
                            : null,
                        tileColor: _optionColor(opt),
                      ),
                    ),
                  ),
                )
                .toList(),
            if (answered) const SizedBox(height: 10),
            if (answered)
              Text(
                isCorrect ? '✅ ตอบถูกต้อง 🎉' : '❌ ผิด ไม่เป็นไรนะ 😢',
                style: TextStyle(
                  fontSize: 18,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  (!answered &&
                          videoEnded &&
                          userAnswers[currentIndex].isNotEmpty &&
                          !isSubmitting) ||
                      (answered && !isSubmitting)
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
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
