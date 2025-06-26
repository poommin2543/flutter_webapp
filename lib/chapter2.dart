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
    '_8XW_BgiD_Q', // ตรวจสอบ ID วิดีโอให้ถูกต้อง
    // 'AvcAVT_XQA0',
    // 'gCahggGt7ao',
    // 'dfofaZaJ3Rc',
    // 'OBnA5HF6kvk', // แก้ไข videoId ให้ตรงกับข้อมูลที่ถูกต้อง
  ];
  final List<String> questions = [
    'จากวิดีโอ สารเคมีใดที่สำคัญที่สุดที่พบในบุหรี่ไฟฟ้าและส่งผลเสียต่อร่างกาย?',
    // 'ผลกระทบของบุหรี่ไฟฟ้าต่อปอดคืออะไร?',
    // 'บุหรี่ไฟฟ้ามีผลต่อสมองวัยรุ่นอย่างไร?',
    // 'ข้อใดไม่ใช่ผลกระทบของบุหรี่ไฟฟ้าต่อหัวใจและหลอดเลือด?',
    // 'การเลิกบุหรี่ไฟฟ้าในวัยรุ่นมีความท้าทายอย่างไรบ้าง?',
  ];
  final List<List<String>> options = [
    ['นิโคติน', 'กลีเซอรอล', 'โพรพิลีนไกลคอล', 'สารแต่งกลิ่น'],
    // ['ทำให้ปอดแข็งแรงขึ้น', 'ทำให้ปอดอักเสบและเสียหาย', 'ช่วยล้างปอด', 'ไม่มีผลกระทบ'],
    // ['ช่วยให้สมองพัฒนาเต็มที่', 'ทำให้สมองถูกทำลายและส่งผลต่อสมาธิ', 'ไม่มีผลกระทบ', 'ช่วยเพิ่มความจำ'],
    // ['เพิ่มความดันโลหิต', 'หัวใจเต้นผิดจังหวะ', 'ทำให้หลอดเลือดขยายตัว', 'เพิ่มความเสี่ยงโรคหัวใจ'],
    // ['ง่ายมาก ไม่ต้องพยายาม', 'ยากเพราะมีอาการถอนนิโคติน', 'สามารถทำได้ด้วยตัวเองเสมอ', 'ไม่มีความท้าทายเลย'],
  ];
  final List<String> answers = [
    'นิโคติน',
    // 'ทำให้ปอดอักเสบและเสียหาย',
    // 'ทำให้สมองถูกทำลายและส่งผลต่อสมาธิ',
    // 'ทำให้หลอดเลือดขยายตัว',
    // 'ยากเพราะมีอาการถอนนิโคติน',
  ];

  int currentIndex = 0;
  late List<String> userAnswers;
  int totalScore = 0;
  bool answered = false;
  bool isCorrect = false;
  String characterImage = 'assets/images/buddy_8.png'; // ใช้รูปเดิมไปก่อน

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
    // โหลดวิดีโอถ้าไม่ใช่ index ที่ 4 ซึ่งจะใช้รูปภาพแทน
    if (idx < videoIds.length) {
      if (idx != 4) { // ถ้าไม่ใช่คำถามที่ 5 (index 4) ให้โหลดวิดีโอ
        _controller.loadVideoById(videoId: videoIds[idx]);
      } else { // ถ้าเป็นคำถามที่ 5 ให้หยุดวิดีโอและไม่โหลดใหม่
        // _controller.stop();
      }
    }
    setState(() {
      answered = false;
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
          'score': totalScore, // คะแนนรวมสำหรับบทเรียนนี้ (หรือคะแนนการพยายามล่าสุด)
          'route_id': widget.routeId,
          'is_finished': isCurrentChapterQuizFinished, // True ถ้าคำถามทั้งหมดใน *บทเรียนนี้* ถูกทำเสร็จแล้ว
          'next_chapter': chapterToAdvanceTo, // บทเรียนที่ผู้ใช้ควรจะก้าวหน้าไป
          'next_route_id': routeIdToAdvanceTo, // เส้นทางที่ผู้ใช้ควรจะก้าวหน้าไป
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

    // หลังจากส่งคะแนน ตรวจสอบว่ายังมีคำถามในบทเรียน *ปัจจุบัน* อีกหรือไม่
    if (currentIndex + 1 < videoIds.length) {
      setState(() {
        currentIndex++;
        _loadVideoAtIndex(currentIndex); // โหลดวิดีโอถัดไปและรีเซ็ตสถานะสำหรับคำถามถัดไป
      });
    } else {
      // คำถามทั้งหมดในบทเรียนนี้ถูกตอบแล้ว
      print('Chapter ${widget.chapter} (Route ${widget.routeId}) finished. Final score: $totalScore');

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
                      chapterDescription: 'กำลังเข้าสู่บทต่อไป...', // สามารถปรับข้อความได้
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
                            setState(() => userAnswers[currentIndex] = val!)),
              ),
            ).toList(),
            if (answered) const SizedBox(height: 10),
            if (answered)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  isCorrect ? '✅ ตอบถูกต้อง 🎉' : '❌ ผิด ลองใหม่นะ 😢',
                  style: TextStyle(
                    fontSize: 18,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
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