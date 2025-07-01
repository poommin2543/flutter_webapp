// lib/chapter4_route2.dart
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'gate_result_page.dart';
import 'constants.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class Chapter4Route2Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId;
  final VoidCallback onFinished;

  Chapter4Route2Page({
    required this.chapter,
    required this.username,
    required this.routeId,
    required this.onFinished,
  });

  @override
  _Chapter4Route2PageState createState() => _Chapter4Route2PageState();
}

class _Chapter4Route2PageState extends State<Chapter4Route2Page> {
  final List<String> questions = [
    "ถ้าเพื่อนชวนลองบุหรี่ไฟฟ้า ควรตัดสินใจอย่างไร?",
    "ถ้าเห็นเพื่อนสูบบุหรี่ไฟฟ้าและรู้สึกลังเล ควร?",
    //"เมื่อต้องตัดสินใจเกี่ยวกับสุขภาพ ควรคำนึงถึง?",
    //"การรู้ข้อมูลโทษของบุหรี่ไฟฟ้าช่วยให้?",
    "หากรู้ว่าใช้แล้วมีโอกาสเสพติด ควร?",
    "ตัดสินใจใช้เพราะ “แค่นิดเดียวไม่เป็นไร” เป็นการตัดสินใจแบบ?",
  ];

  final List<List<String>> options = [
    [
      "ลองเพราะอยากรู้",
      "ปฏิเสธเพราะรู้ผลเสีย",
      "ลองเพื่อให้เข้ากลุ่ม",
      "เฉยๆ ไม่ตอบ",
    ],
    [
      "ถามตัวเองถึงเหตุผลที่ไม่ลอง",
      "เดินหนีทันที",
      "ลองตาม",
      "แชร์คลิปเพื่อนในโซเชียล",
    ],
    //[
    //  "ความสะดวก",
    //  "ความสุขระยะสั้น",
    //  "ความปลอดภัยและผลกระทบระยะยาว",
    //  "ความกล้าหาญ",
    //],
    //["อยากลองมากขึ้น", "ตัดสินใจหลีกเลี่ยงได้ดีขึ้น", "สนใจซื้อ", "เฉยๆ"],
    [
      "หลีกเลี่ยงทันที",
      "ใช้ต่อแต่ลดปริมาณ",
      "ใช้ต่อถ้าเพื่อนยังใช้",
      "คิดทีหลัง",
    ],
    ["รอบคอบ", "มีสติ", "ประมาท", "มีข้อมูล"],
  ];

  final List<String> answers = [
    "ปฏิเสธเพราะรู้ผลเสีย",
    "ถามตัวเองถึงเหตุผลที่ไม่ลอง",
    //"ความปลอดภัยและผลกระทบระยะยาว",
    //"ตัดสินใจหลีกเลี่ยงได้ดีขึ้น",
    "หลีกเลี่ยงทันที",
    "ประมาท",
  ];

  final List<String> scenarioQuestions = [
    "เพื่อนในห้องเรียนเอาบุหรี่ไฟฟ้ามาอวดและพูดว่า สูบแค่พอสนุก ไม่ติดหรอก ลองดูหน่อยไหม?",
    //"เพื่อนในกลุ่มกำลังสูบกันอยู่ แล้วยื่นบุหรี่ไฟฟ้ามาให้คุณและพูดว่า สูบทีนึงก็เท่แล้ว เชื่อสิ?",
    "เพื่อนสนิทบอกว่า “สูบแล้วหายเครียดนะ ลองดูดิ จะได้สบายขึ้น”?",
    //"ในงานเลี้ยง เพื่อนรุ่นพี่ชวนว่า “ลองหน่อย เดี๋ยวดูไม่ทันสมัยนะ”?",
  ];

  final List<List<String>> scenarioOptions = [
    [
      "เอาดิ ลองแค่นิดเดียวเอง",
      "ไม่เอาดีกว่า เราไม่อยากลองอะไรที่อันตราย",
      "เงียบแล้วเดินหนี",
      "เดี๋ยวดูอีกที แล้วค่อยบอก",
    ],
    //[
    //  "รับมาแต่ไม่สูบ",
    //  "ปฏิเสธทันที พร้อมบอกว่า “เราไม่เอา เราไม่ชอบ”",
    //  "ทำเป็นหัวเราะ แล้วเปลี่ยนเรื่อง",
    //  "บอกว่าเดี๋ยวค่อยลองตอนคนอื่นไม่เห็น",
    //],
    [
      "จริงเหรอ ไหนขอลองหน่อย",
      "ถ้าไม่ลอง เดี๋ยวจะไม่สนิทกับเพื่อนละนะ",
      "ขอเก็บไว้ก่อน แล้วค่อยตัดสินใจ",
      "เรามีวิธีคลายเครียดที่ปลอดภัยกว่านี้ ขอบใจนะ",
    ],
    //[
    //  "ไม่จำเป็นต้องทำตามใครถึงจะดูดี เราขอไม่ลองนะ",
    //  "โอเค ลองนิดเดียวพอ",
    //  "เดี๋ยวลองทีหลังคนไม่เยอะ",
    //  "ยิ้มแล้วเปลี่ยนเรื่อง",
    //],
  ];

  final List<String> scenarioAnswers = [
    "ไม่เอาดีกว่า เราไม่อยากลองอะไรที่อันตราย",
    //"ปฏิเสธทันที พร้อมบอกว่า “เราไม่เอา เราไม่ชอบ”",
    "เรามีวิธีคลายเครียดที่ปลอดภัยกว่านี้ ขอบใจนะ",
    //"ไม่จำเป็นต้องทำตามใครถึงจะดูดี เราขอไม่ลองนะ",
  ];

  late List<String> userAnswers;
  int currentIndex = 0;
  int score = 0;
  bool answered = false;
  bool isCorrect = false;
  bool isSubmitting = false;
  int scenarioChatCount = 0;
  bool scenarioQuizShown = false;
  bool isScenarioPending = true;
  bool isScenarioMode = false;
  int scenarioIndex = 0;

  String characterImage = 'assets/images/buddy_8.png';

  final html.AudioElement correctAudio = html.AudioElement(
    'assets/sounds/correct.mp3',
  )..preload = 'auto';
  final html.AudioElement wrongAudio = html.AudioElement(
    'assets/sounds/wrong.mp3',
  )..preload = 'auto';
  final html.AudioElement backgroundAudio =
      html.AudioElement('assets/sounds/background.mp3')
        ..loop = true
        ..autoplay = true
        ..volume = 0.3;

  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  bool _isChatLoading = false;

  @override
  void initState() {
    super.initState();
    userAnswers = List<String>.filled(
      questions.length + scenarioQuestions.length,
      '',
    );
    backgroundAudio.play();
  }

  @override
  void dispose() {
    backgroundAudio.pause();
    backgroundAudio.src = '';
    super.dispose();
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

    if (isCorrect) score++;
    setState(() {});
    await Future.delayed(const Duration(seconds: 2));

    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex++;
        characterImage = 'assets/images/buddy_8.png';
        answered = false;
        isSubmitting = false;
      });
    } else {
      if (isScenarioPending) {
        setState(() {
          isScenarioMode = true;
          scenarioChatCount = 0; // ✅ Reset AI chat count
          isSubmitting = false;
        });
      } else {
        _showFinalScoreDialog();
      }
    }
  }

  Future<void> _submitScoreAndNavigate() async {
    int nextChapter = widget.chapter == 5 ? 1 : widget.chapter + 1;
    int nextRoute = widget.chapter == 5 ? widget.routeId + 1 : widget.routeId;

    try {
      await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'chapter': widget.chapter,
          'score': score,
          'route_id': widget.routeId,
          'is_finished': true,
          'next_chapter': nextChapter,
          'next_route_id': nextRoute,
        }),
      );
    } catch (e) {
      print("Submit failed: $e");
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GateResultPage(
          username: widget.username,
          nextChapter: nextChapter,
          nextRouteId: nextRoute,
          message: 'จบบทที่ ${widget.chapter} แล้ว 🎉',
          chapterDescription: 'กำลังเข้าสู่บทต่อไป...',
        ),
      ),
    );
  }

  void _showFinalScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("สรุปคะแนนทั้งหมด"),
        content: Text("คุณได้คะแนนทั้งหมด $score คะแนน"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ปิด dialog
              _submitScoreAndNavigate(); // แล้วค่อยไปหน้าถัดไป
            },
            child: const Text("ไปต่อ"),
          ),
        ],
      ),
    );
  }

  void _showChatDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: _chatMessages.length,
                      itemBuilder: (_, index) {
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
                      padding: EdgeInsets.all(8),
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
                          onSubmitted: (_) => _sendMessageToN8n(setModalState),
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
      ),
    );
  }

  Future<void> _sendMessageToN8n(StateSetter setModalState) async {
    final userMsg = _chatController.text;
    if (userMsg.isEmpty) return;

    // ✅ อัพเดต chat ก่อน
    setModalState(() {
      _chatMessages.add(ChatMessage(text: userMsg, isUser: true));
      _isChatLoading = true;
    });
    _chatController.clear();

    // ✅ เพิ่มตรงนี้ก่อน await
    bool shouldShowScenario = false;

    try {
      final response = await http.post(
        Uri.parse(
          'https://n8nmoss.roverautonomous.com/webhook/1054bc91-ee04-46fd-94a8-4b2055e6087f',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': widget.username, 'message': userMsg}),
      );

      final reply =
          jsonDecode(response.body)['reply'] ?? 'ขออภัย ฉันไม่เข้าใจ.';
      setModalState(() {
        _chatMessages.add(ChatMessage(text: reply, isUser: false));
      });

      // ✅ ประเมินเงื่อนไขให้แสดง scenario แต่ยังไม่ pop ทันที
      scenarioChatCount++;
      if (isScenarioMode &&
          scenarioChatCount >= 4 &&
          !scenarioQuizShown &&
          isScenarioPending) {
        //if (scenarioChatCount >= 5 && !scenarioQuizShown && isScenarioPending) {
        scenarioQuizShown = true;
        shouldShowScenario = true; // 🔥 จดไว้ก่อน
      }
    } catch (e) {
      setModalState(() {
        _chatMessages.add(ChatMessage(text: 'ข้อผิดพลาด: $e', isUser: false));
      });
    } finally {
      if (mounted) setModalState(() => _isChatLoading = false);

      // ✅ ปิด dialog และเรียก Scenario ภายนอก
      if (shouldShowScenario) {
        Navigator.pop(context);
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) _showScenarioQuiz();
        });
      }
    }
  }

  void _showScenarioQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text("สถานการณ์จำลอง ${scenarioIndex + 1}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(scenarioQuestions[scenarioIndex]),
                  ...scenarioOptions[scenarioIndex].map((opt) {
                    return RadioListTile<String>(
                      title: Text(opt),
                      value: opt,
                      groupValue: userAnswers[questions.length + scenarioIndex],
                      onChanged: (val) {
                        setModalState(
                          () => userAnswers[questions.length + scenarioIndex] =
                              val!,
                        );
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (userAnswers[questions.length + scenarioIndex]
                        .isNotEmpty) {
                      Navigator.pop(context);
                      _submitScenarioAnswer();
                    }
                  },
                  child: const Text("ส่งคำตอบ"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitScenarioAnswer() async {
    final int answerIndex = questions.length + scenarioIndex;
    bool correct = userAnswers[answerIndex] == scenarioAnswers[scenarioIndex];
    if (correct) score++;

    scenarioIndex++;

    if (scenarioIndex < scenarioQuestions.length) {
      // ✅ ใช้ Future.microtask แทน delayed ป้องกัน setState หลัง dispose
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Future.delayed(Duration(milliseconds: 200), () {
            if (mounted) _showScenarioQuiz();
          });
        }
      });
    } else {
      _showFinalScoreDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เส้นทางที่ ${widget.routeId} - บทที่ ${widget.chapter} - ข้อที่ ${currentIndex + 1}/${questions.length}',
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              children: [
                Center(child: Image.asset(characterImage, height: 300)),
                Align(
                  alignment: const Alignment(0.4, -0.4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RawMaterialButton(
                        onPressed: _showChatDialog,
                        elevation: 2.0,
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
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isScenarioMode) ...[
              const Text(
                "สถานการณ์จำลองกำลังจะเริ่ม ถ้าคุณมีคำถาม",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text("คุยกับ AI ให้ครบ 3 - 4 ครั้งก่อนจะมีคำถามโผล่ขึ้นมา"),
            ] else ...[
              Text(
                questions[currentIndex],
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ...options[currentIndex].map(
                (opt) => Card(
                  color: _optionColor(opt),
                  child: RadioListTile<String>(
                    title: Text(opt),
                    value: opt,
                    groupValue: userAnswers[currentIndex],
                    onChanged: (!answered && !isSubmitting)
                        ? (val) =>
                              setState(() => userAnswers[currentIndex] = val!)
                        : null,
                  ),
                ),
              ),
              if (answered)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    isCorrect ? "✅ ตอบถูกต้อง!" : "❌ ยังไม่ถูกนะ",
                    style: TextStyle(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    (!answered &&
                            userAnswers[currentIndex].isNotEmpty &&
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _optionColor(String opt) {
    if (!answered) return Colors.transparent;
    if (opt == answers[currentIndex]) return Colors.green.withOpacity(0.3);
    if (opt == userAnswers[currentIndex] && !isCorrect)
      return Colors.red.withOpacity(0.3);
    return Colors.transparent;
  }
}
