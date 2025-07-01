// lib/chapter3_route2.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'gate_result_page.dart';
import 'constants.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

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

  final List<String> videoIds = ['PlOtMPJpmSk', 'J3Xt44aBxNY'];

  final List<String> questions = [
    'ถ้าเห็นโฆษณาบุหรี่ไฟฟ้าในโซเชียลระบุว่า "ปลอดภัย 100%" ควรทำอย่างไร?',
    'ถ้าโฆษณาใช้คำว่า "ไม่มีกลิ่น ไม่มีอันตราย" หมายความว่าอย่างไร?',
    //'การรู้เท่าทันสื่อช่วยให้เรา?',
    'อินฟลูเอนเซอร์รีวิวบุหรี่ไฟฟ้าโดยไม่บอกว่าได้รับสปอนเซอร์ เป็นตัวอย่างของ?',
    'ถ้ามีเพื่อนชวนลองบุหรี่ไฟฟ้า ควรตอบอย่างไร? (โปรดลองสนทนากับ AI ก่อนตอบคำถาม)',
    'ถ้ารู้สึกไม่มั่นใจในการปฏิเสธ ควรทำอย่างไร? (โปรดลองสนทนากับ AI ก่อนตอบคำถาม)',
    //'หากมีเพื่อนชวนลองอีกครั้ง ควร? (โปรดลองสนทนากับ AI ก่อนตอบคำถาม)',
    //'ถ้ามีคนถามว่าบุหรี่ไฟฟ้าปลอดภัยไหม คำตอบใดเหมาะสม? (โปรดลองสนทนากับ AI ก่อนตอบคำถาม)',
    //'หากเพื่อนไม่พอใจที่เราปฏิเสธ ควร? (โปรดลองสนทนากับ AI ก่อนตอบคำถาม)',
    'ถ้าอยากแนะนำเพื่อนให้เลิกบุหรี่ คำพูดใดดีที่สุด? (โปรดลองสนทนากับ AI ก่อนตอบคำถาม)',
  ];

  final List<List<String>> options = [
    [
      'เชื่อทันที',
      'แชร์ต่อให้เพื่อน',
      'ตั้งข้อสงสัยและหาข้อมูลเพิ่มเติม',
      'ลองใช้ก่อน',
    ],
    [
      'เชื่อได้แน่นอน',
      'เป็นวิธีโฆษณาเกินจริง',
      'ไม่ต้องกังวล',
      'หมายถึงปลอดภัยเสมอ',
    ],
    //[
    //  'รู้ทันกลเม็ดการตลาด',
    //  'สนับสนุนโฆษณา',
    //  'ตัดสินใจซื้อสินค้าได้ไว',
    //  'แชร์โพสต์ทันที',
    //],
    [
      'การสื่อสารสร้างสรรค์',
      'การโฆษณาแบบหลอกลวง',
      'การให้ความรู้',
      'การแนะนำผลิตภัณฑ์เพื่อสุขภาพ',
    ],
    [
      'ก็ได้นะ แค่นิดเดียว',
      'ไม่เอา ขอบใจนะ เราไม่อยากลอง',
      'ไว้วันหลังค่อยลอง',
      'แล้วแต่เพื่อนจะให้',
    ],
    [
      'ปล่อยให้เพื่อนตัดสินใจแทน',
      'เงียบ',
      'ซ้อมพูดปฏิเสธกับผู้ใหญ่หรือครู',
      'ยอมทำตาม',
    ],
    //[
    //  'ลองเลย',
    //  'ตอบเสียงดัง',
    //  'พูดซ้ำอย่างสุภาพว่า “ไม่ลอง”',
    //  'เดินหนีโดยไม่พูด',
    //],
    //[
    //  'ไม่แน่ใจ ลองไปเลยดีกว่า',
    //  'ไม่น่าอันตรายเพราะไม่มีกลิ่น',
    //  'บุหรี่ไฟฟ้ามีสารอันตรายต่อร่างกาย',
    //  'ทุกคนก็ลองกัน',
    //],
    //[
    //  'ขอโทษแล้วเปลี่ยนใจ',
    //  'อธิบายเหตุผลอย่างสุภาพ',
    //  'เถียงกลับ',
    //  'ทำตามเพื่อน',
    //],
    [
      'มันแย่มากเลยนะ',
      'ไม่ดีเลย เลิกเถอะ',
      'เราห่วงสุขภาพนายจริงๆ',
      'สูบต่อไปเถอะ เราไม่ห้าม',
    ],
  ];

  final List<String> answers = [
    'ตั้งข้อสงสัยและหาข้อมูลเพิ่มเติม',
    'เป็นวิธีโฆษณาเกินจริง',
    //'รู้ทันกลเม็ดการตลาด',
    'การโฆษณาแบบหลอกลวง',
    'ไม่เอา ขอบใจนะ เราไม่อยากลอง',
    'ซ้อมพูดปฏิเสธกับผู้ใหญ่หรือครู',
    //'พูดซ้ำอย่างสุภาพว่า “ไม่ลอง”',
    //'บุหรี่ไฟฟ้ามีสารอันตรายต่อร่างกาย',
    //'อธิบายเหตุผลอย่างสุภาพ',
    'เราห่วงสุขภาพนายจริงๆ',
  ];

  int currentIndex = 0;
  late List<String> userAnswers;
  int totalScore = 0;
  bool answered = false;
  bool isCorrect = false;
  bool isSubmitting = false;
  bool videoEnded = false;
  String characterImage = 'assets/images/buddy_8.png';
  bool hasChattedThisQuestion = false;

  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  bool _isChatLoading = false;
  int chatCount = 0;

  void _showChatDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, index) {
                          final msg = _chatMessages.reversed.toList()[index];
                          return Align(
                            alignment: msg.isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: msg.isUser
                                    ? Colors.blue[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: msg.isUser
                                  ? Text(msg.text)
                                  : MarkdownBody(data: msg.text),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_isChatLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: InputDecoration(
                              hintText: 'ถาม AI ได้เลย...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onSubmitted: (_) =>
                                _sendMessageToN8n(setModalState),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => _sendMessageToN8n(setModalState),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  final html.AudioElement backgroundAudio =
      html.AudioElement('assets/sounds/background.mp3')
        ..loop = true
        ..autoplay = true
        ..volume = 0.3;

  @override
  void initState() {
    super.initState();
    backgroundAudio.play();
    userAnswers = List.filled(questions.length, '');
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoIds[0],
      params: const YoutubePlayerParams(
        showFullscreenButton: false,
        showControls: false,
      ),
    );

    _loadVideoAtIndex(0);
    _controller.listen((event) {
      if (event.playerState == PlayerState.ended) {
        setState(() => videoEnded = true);
        backgroundAudio.volume = 0.3; // 🔊 เพิ่มเสียงกลับ
      } else if (event.playerState == PlayerState.playing) {
        backgroundAudio.volume = 0.05; // 🔇 ลดเสียงขณะเล่นวิดีโอ
      }
    });
    if (currentIndex > 1) videoEnded = true;
  }

  @override
  void dispose() {
    backgroundAudio.pause();
    backgroundAudio.src = '';
    _controller.close();
    super.dispose();
  }

  void _loadVideoAtIndex(int idx) {
    hasChattedThisQuestion =
        idx < 3; // ✅ ตรวจจากข้อที่จะโหลด ไม่ใช่ currentIndex เก่า
    //idx < 4; // ✅ ตรวจจากข้อที่จะโหลด ไม่ใช่ currentIndex เก่า

    if (idx < videoIds.length) {
      _controller.loadVideoById(videoId: videoIds[idx]);
      videoEnded = false;
    } else {
      videoEnded = true;
    }

    setState(() {
      answered = false;
      isSubmitting = false;
      userAnswers[idx] = '';
      characterImage = 'assets/images/buddy_8.png';
    });
  }

  Future<void> _sendMessageToN8n(StateSetter setModalState) async {
    final userMsg = _chatController.text;
    if (userMsg.isEmpty) return;

    setModalState(() {
      _chatMessages.add(ChatMessage(text: userMsg, isUser: true));
      _isChatLoading = true;
    });
    _chatController.clear();

    try {
      final response = await http.post(
        Uri.parse(
          'https://n8nmoss.roverautonomous.com/webhook/1054bc91-ee04-46fd-94a8-4b2055e6087f',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': widget.username, 'message': userMsg}),
      );

      if (response.statusCode == 200) {
        final reply =
            jsonDecode(response.body)['reply'] ?? 'ขออภัย ฉันไม่เข้าใจ.';
        setModalState(() {
          _chatMessages.add(ChatMessage(text: reply, isUser: false));
          chatCount++;
        });
      } else {
        setModalState(() {
          _chatMessages.add(
            ChatMessage(text: 'ผิดพลาด: ${response.statusCode}', isUser: false),
          );
        });
      }
    } catch (e) {
      setModalState(() {
        _chatMessages.add(
          ChatMessage(text: 'เชื่อมต่อไม่ได้: $e', isUser: false),
        );
      });
    } finally {
      setModalState(() => _isChatLoading = false);
    }

    if (!hasChattedThisQuestion && currentIndex >= 3) {
      //if (!hasChattedThisQuestion && currentIndex >= 4) {
      setState(() => hasChattedThisQuestion = true);
    }
  }

  Future<void> _submitAnswer() async {
    if (answered || isSubmitting) return;

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
    if (isCorrect) totalScore++;

    bool isFinished = (currentIndex + 1 >= questions.length);
    int nextChapter = widget.chapter;
    int nextRoute = widget.routeId;

    if (isFinished) {
      if (widget.chapter == 5) {
        nextChapter = 1;
        nextRoute++;
      } else {
        nextChapter++;
      }
    }

    try {
      await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'chapter': widget.chapter,
          'score': totalScore,
          'route_id': widget.routeId,
          'is_finished': isFinished,
          'next_chapter': nextChapter,
          'next_route_id': nextRoute,
        }),
      );
    } catch (e) {
      print('Error submitting score: $e');
    }

    if (!isFinished) {
      setState(() {
        currentIndex++;
        _loadVideoAtIndex(currentIndex);
      });
    } else {
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
                      message:
                          'จบบทที่ ${widget.chapter} เส้นทางที่ ${widget.routeId} แล้ว 🎉',
                      nextChapter: nextChapter,
                      nextRouteId: nextRoute,
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
          'เส้นทางที่ ${widget.routeId} - บทที่ ${widget.chapter} – ข้อที่ ${currentIndex + 1}/${questions.length}',
        ),
        automaticallyImplyLeading: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(characterImage, height: 400),
                    const SizedBox(width: 20),
                    if (currentIndex < videoIds.length)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 400,
                        child: YoutubePlayer(controller: _controller),
                      ),
                  ],
                ),
                //if (currentIndex >= 4)
                if (currentIndex >= 3)
                  Align(
                    alignment: const Alignment(0.4, -0.4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RawMaterialButton(
                          onPressed: _showChatDialog,
                          elevation: 4.0,
                          fillColor: Colors.blue,
                          shape: const CircleBorder(),
                          constraints: const BoxConstraints.tightFor(
                            width: 160,
                            height: 160,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'กดเพื่อเปิดกล่องข้อความ AI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              questions[currentIndex],
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (currentIndex < videoIds.length && !videoEnded)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'กรุณาชมวิดีโอให้จบก่อนเลือกคำตอบ',
                  style: TextStyle(color: Colors.red, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            ...options[currentIndex].map(
              (opt) => Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Card(
                  color: _optionColor(opt),
                  child: RadioListTile<String>(
                    title: Text(opt, textAlign: TextAlign.center),
                    value: opt,
                    groupValue: userAnswers[currentIndex],
                    onChanged:
                        (!answered &&
                            videoEnded &&
                            !isSubmitting &&
                            hasChattedThisQuestion)
                        ? (val) =>
                              setState(() => userAnswers[currentIndex] = val!)
                        : null,
                  ),
                ),
              ),
            ),
            if (answered)
              Padding(
                padding: const EdgeInsets.only(top: 12),
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
              onPressed:
                  (!answered &&
                          userAnswers[currentIndex].isNotEmpty &&
                          videoEnded &&
                          !isSubmitting) ||
                      (answered && !isSubmitting)
                  ? _submitAnswer
                  : null,
              child: Text(
                answered
                    ? (currentIndex + 1 < questions.length ? 'ถัดไป' : 'ส่ง')
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
