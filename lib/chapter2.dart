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
    '_8XW_BgiD_Q',
    'dfofaZaJ3Rc',
    'gCahggGt7ao',
    'WwSfLUtrx_Y',
    'ZnuO_wbMu9I', // แก้ไข videoId ให้ตรงกับข้อมูลที่ถูกต้อง
    // แก้ไข videoId ให้ตรงกับข้อมูลที่ถูกต้อง
  ];
  final List<String> questions = [
    'บุหรี่ไฟฟ้ามีสิ่งใดที่สามารถชักจูงให้เยาวชนสนใจ?',
    'สาเหตุที่เยาวชนเริ่มสูบบุหรี่ไฟฟ้าได้แก่อะไร?',
    'อันตรายจากสารพิษในบุหรี่ไฟฟ้าส่งผลกระทบต่อส่วนใดของร่างกาย?',
    'บุหรี่ไฟฟ้าผิดกฏหมายในประเทศไทยหรือไม่?',
    'ข้อใดคือความเข้าใจผิดเกี่ยวกับบุหรี่ไฟฟ้า?',
  ];
  final List<List<String>> options = [
    ['กลิ่นหอม รูปลักษณ์', 'มีสารเสพติด', 'ปลอดภัยกว่าบุหรี่มวน', 'มีความเทห์'],
    ['มีความอันตรายน้อย', 'สื่อชักชวน', 'ควันมือสอง', 'เพื่อนชักชวน'],
    ['ไต', 'อวัยวะทุกส่วนในร่างกาย', 'หัวใจ', 'ข้อกระดูก'],
    [
      'ถูกกฏหมาย',
      'ผิดกฏหมายเฉพาะผู้นำเข้า',
      'ผิดกฏหมายเฉพาะผู้ขาย',
      'ผิดกฏหมายทั้งหมดไม่ว่ากรณีใดก็ตาม',
    ],
    [
      'มีสารเคมีหลายชนิดที่อาจส่งผลต่อปอด',
      'วัยรุ่นจำนวนมากเริ่มสูบเพราะกลิ่นและรสชาติ',
      'ไม่มีสารนิโคติน',
      'การสูบบุหรี่ไฟฟ้าอาจทำให้เสพติดได้',
    ],
  ];
  final List<String> answers = [
    'กลิ่นหอม รูปลักษณ์',
    'เพื่อนชักชวน',
    'อวัยวะทุกส่วนในร่างกาย',
    'ผิดกฏหมายทั้งหมดไม่ว่ากรณีใดก็ตาม',
    'ไม่มีสารนิโคติน',
  ];

  int currentIndex = 0;
  late List<String> userAnswers;
  int totalScore = 0;
  bool answered = false;
  bool isCorrect = false;
  String characterImage = 'assets/images/buddy_8.png'; // ใช้รูปเดิมไปก่อน
  bool videoEnded = false;

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

    // 👇 Add this listener
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
    backgroundAudio.pause(); // Stop audio
    backgroundAudio.src = ''; // Clean up
    _controller.close();
    super.dispose();
  }

  void _loadVideoAtIndex(int idx) {
    // โหลดวิดีโอถ้าไม่ใช่ index ที่ 4 ซึ่งจะใช้รูปภาพแทน
    if (idx < videoIds.length) {
      if (idx != 51) {
        // ถ้าไม่ใช่คำถามที่ 5 (index 4) ให้โหลดวิดีโอ
        _controller.loadVideoById(videoId: videoIds[idx]);
      } else {
        // ถ้าเป็นคำถามที่ 5 ให้หยุดวิดีโอและไม่โหลดใหม่
        // _controller.stop();
      }
    }
    setState(() {
      answered = false;
      videoEnded = false; // 🔁 Reset this for the new video
      userAnswers[idx] = ''; // Reset user's answer for the new question
      characterImage = 'assets/images/buddy_8.png'; // Revert character image
    });
  }

  Future<void> _submitAnswer() async {
    // ป้องกันการส่งคำตอบซ้ำ

    if (answered) return;

    isCorrect = userAnswers[currentIndex] == answers[currentIndex];
    answered = true; // ทำเครื่องหมายว่าตอบแล้วเพื่อแสดงผล
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

    setState(() {}); // อัปเดต UI เพื่อแสดงผลลัพธ์และตัวละคร

    await Future.delayed(const Duration(seconds: 2)); // รอ 2 วินาที

    // อัปเดตคะแนนหลังจากรอ ก่อนที่จะย้ายไปคำถามถัดไป/จบบทเรียน
    if (isCorrect) {
      totalScore++;
    }

    // ตรวจสอบว่าคำถามทั้งหมดในบทเรียนปัจจุบันถูกตอบแล้วหรือไม่
    bool isCurrentChapterQuizFinished = (currentIndex + 1 >= videoIds.length);

    int chapterToAdvanceTo = widget.chapter; // ค่าเริ่มต้นคือบทปัจจุบัน
    int routeIdToAdvanceTo = widget.routeId; // ค่าเริ่มต้นคือเส้นทางปัจจุบัน

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

    // ส่งคะแนนและสถานะความคืบหน้าไปยัง Backend (ส่งเสมอ ไม่ว่าจะจบบทหรือไม่)
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'chapter': widget.chapter, // หมายถึงบทที่เพิ่งทำเสร็จ/พยายามทำ
          'score':
              totalScore, // คะแนนรวมสำหรับบทเรียนนี้ (หรือคะแนนการพยายามล่าสุด)
          'route_id': widget.routeId,
          'is_finished':
              isCurrentChapterQuizFinished, // True ถ้าคำถามทั้งหมดใน *บทเรียนนี้* ถูกทำเสร็จแล้ว
          'next_chapter': chapterToAdvanceTo, // บทเรียนที่ผู้ใช้ควรจะก้าวหน้าไป
          'next_route_id':
              routeIdToAdvanceTo, // เส้นทางที่ผู้ใช้ควรจะก้าวหน้าไป
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

    // หลังจากส่งคะแนน ตรวจสอบว่ายังมีคำถามในบทเรียน *ปัจจุบัน* อีกหรือไม่
    if (currentIndex + 1 < videoIds.length) {
      setState(() {
        currentIndex++;
        _loadVideoAtIndex(
          currentIndex,
        ); // โหลดวิดีโอถัดไปและรีเซ็ตสถานะสำหรับคำถามถัดไป
      });
    } else {
      // คำถามทั้งหมดในบทเรียนนี้ถูกตอบแล้ว
      print(
        'Chapter ${widget.chapter} (Route ${widget.routeId}) finished. Final score: $totalScore',
      );

      if (!mounted) return; // ตรวจสอบว่า Widget ยังอยู่ใน Tree ก่อนแสดง Dialog
      showDialog(
        context: context,
        barrierDismissible: false, // ป้องกันการปิด Dialog โดยการแตะด้านนอก
        builder: (context) => AlertDialog(
          title: const Text("คะแนนของคุณ"),
          content: Text("คุณได้ $totalScore จาก ${answers.length} ข้อ"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ปิด Dialog
                // นำทางไป GateResultPage เพื่อไปยังบทเรียนถัดไปหรือเส้นทางถัดไป
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GateResultPage(
                      username: widget.username,
                      nextChapter: chapterToAdvanceTo, // ส่งบทเรียนที่คำนวณแล้ว
                      nextRouteId: routeIdToAdvanceTo, // ส่งเส้นทางที่คำนวณแล้ว
                      message: 'จบบทที่ ${widget.chapter} แล้ว 🎉',
                      chapterDescription:
                          'กำลังเข้าสู่บทต่อไป...', // สามารถปรับข้อความได้
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
                Image.asset(
                  characterImage,
                  height: 400,
                ), // Resize image as needed
                const SizedBox(width: 20), // Space between image and video
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
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (!videoEnded)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'กรุณาชมวิดีโอให้จบก่อนเลือกคำตอบ',
                  style: TextStyle(color: Colors.red, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
            ...options[currentIndex]
                .map(
                  (opt) => Container(
                    width:
                        MediaQuery.of(context).size.width *
                        0.5, // 80% of screen width
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
                        title: Text(
                          opt,
                          style: const TextStyle(
                            fontSize: 24,
                          ), // Resize font here
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
                      ),
                    ),
                  ),
                )
                .toList(),
            if (answered) const SizedBox(height: 10),
            if (answered)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  isCorrect ? '✅ ตอบถูกต้อง 🎉' : '❌ ผิด ไม่เป็นไรนะ 😢',
                  style: TextStyle(
                    fontSize: 18,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (!videoEnded || answered)
                  ? null
                  : (userAnswers[currentIndex].isNotEmpty
                        ? _submitAnswer
                        : null),
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
                textStyle: const TextStyle(fontSize: 18),
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
