import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'summary_page.dart';
import 'constants.dart';

class Chapter5Route2Page extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId;
  final VoidCallback onFinished;

  Chapter5Route2Page({
    required this.chapter,
    required this.username,
    required this.routeId,
    required this.onFinished,
  });

  @override
  _Chapter5Route2PageState createState() => _Chapter5Route2PageState();
}

class _Chapter5Route2PageState extends State<Chapter5Route2Page> {
  final List<String> questions = [
    '''
ต้นเป็นนักเรียน ม.2 ที่มักจะตั้งใจเรียนเสมอ. แต่ช่วงนี้เขารู้สึกเครียดและหมดกำลังใจ. 
เพราะคะแนนสอบตกหลายวิชา. และครูก็พูดต่อหน้าห้องว่า, "ต้นต้องปรับปรุงนะ. ไม่อย่างนั้นจะเรียนต่อ ม.3 ยาก."

กลับถึงบ้าน, พ่อกับแม่ก็ยุ่งกับงาน. ไม่ได้มีเวลาเปิดใจคุยกันเหมือนเคย. 
ต้นรู้สึกโดดเดี่ยว. ไม่กล้าบอกใครว่ากำลังเครียดและสับสน.

วันหนึ่งหลังเลิกเรียน, เพื่อนกลุ่มหนึ่งชวนต้นไปนั่งเล่นข้างสนามกีฬา. 
ระหว่างนั่งคุยกัน, เพื่อนคนหนึ่งหยิบบุหรี่ไฟฟ้ากลิ่นผลไม้ออกมา แล้วพูดว่า:

"เฮ้, ลองดูดิ. สูบแล้วรู้สึกสบายขึ้นเยอะเลยนะ. พวกเราทุกคนก็ลองแล้ว. นายเองก็คงเครียดอยู่ใช่มั้ย?"

ต้นลังเลในใจ. เขารู้ว่ามันอาจไม่ดี. แต่ก็รู้สึกว่าไม่มีใครเข้าใจเขา. 
และอาจจะลองสักหน่อย, เพื่อคลายความรู้สึกแย่ ๆ ที่มีอยู่.
''',

    '''แพร เป็นเด็ก ม.2 ที่เงียบขรึมและมีความรับผิดชอบ. เธอช่วยพ่อแม่ทำงานบ้านเสมอ และพยายามตั้งใจเรียน. แต่ช่วงนี้แพรกำลังเครียดเรื่องที่บ้าน.

พ่อแม่ของแพรมักทะเลาะกันเสียงดังทุกวันเกี่ยวกับปัญหาเงินทอง. บางครั้งพ่อก็หงุดหงิดใส่แพร ทั้งที่เธอไม่ได้ทำอะไรผิด.

แพรเริ่มรู้สึกว่าบ้านไม่ใช่ที่ที่เธอรู้สึกปลอดภัยอีกต่อไป. เธอไม่มีที่ให้ระบาย เพราะไม่กล้าคุยกับใคร. แม้แต่เพื่อนสนิทก็ไม่รู้ว่าเธอกำลังเผชิญอะไรอยู่.

วันหนึ่ง เพื่อนในโรงเรียนมาชวนเธอว่า: “ลองสูบบุหรี่ไฟฟ้าดูมั้ย? มันช่วยให้ลืมเรื่องที่บ้านได้. เราเข้าใจเธอนะ.”

แพรลังเล. ในใจรู้ว่ามันไม่ดี. แต่ก็เหนื่อย และไม่มีที่พึ่ง.''',

    '''เมฆ เป็นนักเรียน ม.3 ที่เพิ่งย้ายโรงเรียนกลางเทอม. เขาไม่ค่อยมีเพื่อนในห้อง และมักใช้เวลาพักคนเดียว.

วันหนึ่ง เขาเห็นเพื่อนกลุ่มหนึ่งที่ดูสนิทกันมาก กำลังหัวเราะและสูบบุหรี่ไฟฟ้าหลังโรงเรียน.

เพื่อนในกลุ่มเห็นเมฆเดินผ่าน จึงเรียกมาทัก และพูดว่า: “เฮ้ มานั่งด้วยกันสิ. เรากำลังลองกลิ่นใหม่อยู่. ลองหน่อยสิ จะได้สนิทกันไว ๆ.”

เมฆรู้สึกดีที่มีคนชวนคุยเป็นครั้งแรก. แต่ก็ไม่แน่ใจว่าจะทำอย่างไรดี เพราะเขาไม่เคยลองบุหรี่ไฟฟ้ามาก่อน.''',

    //"ฟ้า เป็นนักเรียนหญิง ม.2 ที่ชอบดูคลิป TikTok และ YouTube เป็นประจำ วันหนึ่งเธอเจอคลิปรีวิวบุหรี่ไฟฟ้าโดย Influencer คนหนึ่งที่เธอติดตามมานาน\n\n"
    //    "ในคลิปนั้น Influencer พูดว่า: นี่คือกลิ่นใหม่ของปีนี้ กลิ่นองุ่นเย็น สูบแล้วสดชื่น ไม่เหม็นติดเสื้อผ้าเลย ใครยังไม่ลอง ถือว่าเอ้าท์!\n\n"
    //    "พร้อมกับท่าทางน่ารัก เท่ และมีเพลงประกอบยอดนิยม ฟ้ารู้สึกว่า มันก็ดูน่ารักดีนะ วันต่อมา มีเพื่อนในห้องพูดว่า เห็นคลิปนั้นยัง ฟ้าต้องลองบ้างแล้วแหละ จะได้เท่เหมือนเขา\n\n"
    //    "ฟ้ารู้สึกอยากลอง ทั้งจากความอยากรู้ และจากความกดดันจากเพื่อน",

    //"เบนซ์ เป็นนักเรียน ม.2 ที่อาศัยอยู่กับพี่ชายวัยมหาวิทยาลัย พี่ชายของเขาเป็นคนเก่ง เรียนดี มีเพื่อนเยอะ และมักเป็นคนที่เบนซ์ชื่นชมมาตั้งแต่เด็ก\n\n"
    //   "วันหนึ่ง เบนซ์เดินเข้าไปในห้องของพี่ชายแล้วเห็นพี่กำลังสูบบุหรี่ไฟฟ้าอยู่ พี่ชายพูดขึ้นมาว่า: “โตขึ้นนายน่าจะลองบ้างนะ มันช่วยให้ผ่อนคลายเวลาทำงานหนัก”\n\n"
    //    "เบนซ์รู้สึกสับสนในใจ เขาเคยเรียนในห้องว่าบุหรี่ไฟฟ้าอันตราย แต่พี่ชายก็เป็นคนที่เขาเชื่อและอยากเป็นแบบ",
    "ถ้าอยากมีความภาคภูมิใจในตนเอง เราควร?",
    "ถ้ามีความรู้สึกอยากลองบ่อย ควร?",
    "ถ้าถูกล้อว่า “เด็กเรียนไม่กล้าลอง” ควร?",
    //"ถ้ารู้สึกเครียดและอยากลองสิ่งใหม่ ควรทำอย่างไร?",
    //"ถ้ารู้สึกภาคภูมิใจที่ไม่ตกเป็นเหยื่อของบุหรี่ไฟฟ้า แสดงว่า?",
  ];

  final List<List<String>> options = [
    [
      "ปฏิเสธอย่างสุภาพว่า “เราขอไม่ลองนะ เรากำลังพยายามหาทางจัดการความเครียดด้วยวิธีอื่น” แล้วเดินออกมาหาที่เงียบ ๆ ระบายอารมณ์",
      "ลองดูสักครั้งเพราะอยากรู้ว่ามันจะช่วยจริงไหม แล้วค่อยหยุดทีหลัง",
      "ไม่พูดอะไร รับบุหรี่ไฟฟ้ามาแล้วเก็บไว้ในกระเป๋า เพราะไม่อยากให้เพื่อนรู้ว่าเราไม่กล้า",
      "แกล้งหัวเราะ แล้วพูดว่า “ไว้ค่อยลองละกัน” เพื่อเลี่ยงสถานการณ์ชั่วคราว",
    ],
    [
      "พูดขอบคุณเพื่อนที่เข้าใจ แต่บอกว่า “เราขอหาวิธีที่ปลอดภัยกว่านี้นะ” แล้วลองเขียนไดอารี่หรือขอคำปรึกษาจากครูที่ไว้ใจได้",
      "ไม่พูดอะไร หยิบบุหรี่ไฟฟ้ามาสูบ เพราะไม่รู้จะหันไปพึ่งใคร",
      "รับมาไว้ก่อน แต่ยังไม่สูบ เพราะอยากรู้ว่ามันช่วยได้จริงไหม",
      "โพสต์ระบายในโซเชียลด้วยข้อความเศร้า แล้วรอคนมาเห็นใจ",
    ],

    [
      "ยอมลองสูบเพื่อให้ได้เข้ากลุ่ม แล้วค่อยหยุดทีหลัง",
      "ปฏิเสธทันทีแล้วเดินหนี ไม่พูดอะไร",
      "หัวเราะกลบเกลื่อน แล้วบอกว่า “ไว้คราวหน้าละกัน”",
      "บอกขอบคุณเพื่อน และตอบว่า “เราดีใจที่ได้รู้จักนะ แต่ขอไม่สูบ เราขอแค่นั่งคุยด้วยได้ไหม”",
    ],

    //[
    //  "แสดงความคิดเห็นใต้คลิปว่า “อยากลองบ้างแล้ว”",
    //  "เตือนตัวเองว่า influencer ไม่ใช่ผู้เชี่ยวชาญ และรีวิวบางอย่างอาจทำให้เราเข้าใจผิด",
    //  "แชร์คลิปนั้นต่อให้เพื่อนในกลุ่มดู",
    //  "ไปซื้อบุหรี่ไฟฟ้ามาลองเอง เพราะอยากรู้ว่าจริงไหม",
    //],

    //[
    //  "รู้สึกเท่ตาม แล้วขอพี่ชายลองดูบ้าง",
    //  "ถ่ายรูปพี่ชายไว้ แล้วส่งให้เพื่อนในกลุ่มดู",
    //  "เตือนตัวเองว่าแม้พี่ชายจะเป็นแบบอย่างที่ดีหลายด้าน แต่เรื่องนี้อาจไม่ใช่สิ่งที่ควรทำตาม และเลือกที่จะไม่ลอง",
    //  "ไม่พูดอะไร แล้วเก็บความสงสัยไว้ในใจ",
    //],
    [
      "ทำตามเพื่อน ",
      "เลือกสิ่งที่ดีให้กับตัวเอง",
      "ทำให้คนอื่นชอบ",
      "ลองดูให้รู้",
    ],
    ["เขียนบันทึกความคิดตัวเอง", "ปล่อยผ่าน", "กดดันตัวเอง", "ซ่อนความคิด"],
    [
      "ลองให้ดู",
      "อธิบายด้วยความมั่นใจว่าเราไม่สนใจ",
      "เงียบแล้วเดินหนี",
      "หัวเราะตาม",
    ],
    //[
    //  "ใช้บุหรี่ไฟฟ้าคลายเครียด",
    // "เล่นกีฬา/วาดภาพ/พูดคุยกับคนที่ไว้ใจ",
    //  " ลองใช้สิ่งแปลกใหม่",
    //  "เฉยๆ แล้วปล่อยไป",
    //],
    //["มีความมั่นใจในตนเอง", "ดื้อ", "กลัวเพื่อน", "เก็บกด"],
  ];

  final List<String> answers = [
    "ปฏิเสธอย่างสุภาพว่า “เราขอไม่ลองนะ เรากำลังพยายามหาทางจัดการความเครียดด้วยวิธีอื่น” แล้วเดินออกมาหาที่เงียบ ๆ ระบายอารมณ์",
    "พูดขอบคุณเพื่อนที่เข้าใจ แต่บอกว่า “เราขอหาวิธีที่ปลอดภัยกว่านี้นะ” แล้วลองเขียนไดอารี่หรือขอคำปรึกษาจากครูที่ไว้ใจได้",
    "บอกขอบคุณเพื่อน และตอบว่า “เราดีใจที่ได้รู้จักนะ แต่ขอไม่สูบ เราขอแค่นั่งคุยด้วยได้ไหม”",
    //"เตือนตัวเองว่า influencer ไม่ใช่ผู้เชี่ยวชาญ และรีวิวบางอย่างอาจทำให้เราเข้าใจผิด",
    //"เตือนตัวเองว่าแม้พี่ชายจะเป็นแบบอย่างที่ดีหลายด้าน แต่เรื่องนี้อาจไม่ใช่สิ่งที่ควรทำตาม และเลือกที่จะไม่ลอง",
    "เลือกสิ่งที่ดีให้กับตัวเอง",
    "เขียนบันทึกความคิดตัวเอง",
    "อธิบายด้วยความมั่นใจว่าเราไม่สนใจ",
    //"เล่นกีฬา/วาดภาพ/พูดคุยกับคนที่ไว้ใจ",
    //"มีความมั่นใจในตนเอง",
  ];

  final List<String> Sub_questions = [
    "ถ้าคุณเป็นต้น คุณจะจัดการกับสถานการณ์นี้อย่างไร เพื่อไม่ตกอยู่ในความเสี่ยง และรักษาความรู้สึกของตัวเองให้อยู่ในทางที่ดี?",
    "ถ้าคุณเป็นแพร คุณจะทำอย่างไรเพื่อตอบสนองต่อความเครียดนี้ โดยไม่เลือกเสี่ยงกับการใช้บุหรี่ไฟฟ้า?",
    "ถ้าคุณเป็นเมฆ คุณจะทำอย่างไรเพื่อไม่เสียโอกาสสร้างมิตรภาพ แต่ยังคงยึดมั่นในสิ่งที่ถูกต้อง?",
    //"ถ้าคุณเป็นฟ้า คุณจะจัดการกับความรู้สึกอยากลองจากสิ่งที่เห็นในโซเชียลอย่างไร?",
    //"ถ้าคุณเป็นเบนซ์ คุณจะควบคุมความรู้สึกและการตัดสินใจของตัวเองอย่างไรในสถานการณ์นี้?",
    " ",
    " ",
    " ",
    //" ",
    //" ",
  ];

  late List<String> userAnswers;
  int currentIndex = 0;
  int score = 0;
  bool answered = false;
  bool isSubmitting = false;
  bool isCorrect = false;
  final html.SpeechSynthesis synth = html.window.speechSynthesis!;

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

  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(questions.length, "");
    backgroundAudio.play();
    _speakIfNeeded();
  }

  @override
  void dispose() {
    backgroundAudio.pause();
    backgroundAudio.src = '';
    super.dispose();
  }

  void _speakIfNeeded() {
    //if (kIsWeb && currentIndex < 5) {
    if (kIsWeb && currentIndex < 3) {
      _speak(questions[currentIndex]);
    }
  }

  void _speak(String text) {
    if (!kIsWeb) return;

    final synth = html.window.speechSynthesis;
    if (synth != null) {
      final utterance = html.SpeechSynthesisUtterance(text)
        ..lang = 'th-TH'
        ..rate = 0.85
        ..pitch = 1.2
        ..volume = 1.0;

      final voices = synth.getVoices();

      // ✅ ป้องกัน voices ว่าง (ซึ่งจะทำให้ .first error)
      if (voices.isNotEmpty) {
        final thaiVoice = voices.firstWhere(
          (v) => v.lang == 'th-TH',
          orElse: () => voices.first,
        );
        utterance.voice = thaiVoice;
      }

      synth.cancel();
      synth.speak(utterance);
    } else {
      print('❗ speechSynthesis ไม่พร้อมใช้งานบนเบราว์เซอร์นี้');
    }
  }

  Future<void> _submitAnswer() async {
    if (answered || isSubmitting) return;
    setState(() => isSubmitting = true);

    isCorrect = userAnswers[currentIndex] == answers[currentIndex];
    if (isCorrect) {
      score++;
      correctAudio.currentTime = 0;
      correctAudio.play();
    } else {
      wrongAudio.currentTime = 0;
      wrongAudio.play();
    }

    setState(() {
      characterImage = isCorrect
          ? 'assets/images/buddy_8c.gif'
          : 'assets/images/buddy_8w.gif';
      answered = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex++;
        answered = false;
        isSubmitting = false;
        characterImage = 'assets/images/buddy_8.png';
      });
      _speakIfNeeded();
    } else {
      _showResultDialog();
    }
  }

  void _showTextDialog(String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เนื้อหาสถานการณ์"),
        content: SingleChildScrollView(
          child: Text(text, style: const TextStyle(fontSize: 20)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ปิด", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void _showResultDialog() async {
    // ส่งคะแนนไป Backend
    bool isCurrentChapterQuizFinished = true; // จบบทแน่นอน
    int chapterToAdvanceTo = widget.chapter;
    int routeIdToAdvanceTo = widget.routeId;

    if (isCurrentChapterQuizFinished) {
      chapterToAdvanceTo = 1; // ไป Chapter แรกของเส้นทางใหม่
      routeIdToAdvanceTo = widget.routeId + 1; // ไป Route ถัดไป
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'chapter': widget.chapter,
          'score': score,
          'route_id': widget.routeId,
          'is_finished': isCurrentChapterQuizFinished,
          'next_chapter': chapterToAdvanceTo,
          'next_route_id': routeIdToAdvanceTo,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Score submitted successfully!');
      } else {
        print('❌ Failed to submit score: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 Error submitting score: $e');
    }

    // แสดงผลคะแนน
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("คะแนนของคุณ"),
        content: Text("คุณได้คะแนน $score จาก ${questions.length} ข้อ"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SummaryPage(username: widget.username),
                ),
              );
            },
            child: const Text("ตกลง"),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    //final bool isVoiceQuestion = currentIndex < 5;
    final bool isVoiceQuestion = currentIndex < 3;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เส้นทาง ${widget.routeId} - บท ${widget.chapter} - ข้อที่ ${currentIndex + 1}/${questions.length}',
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
              ],
            ),
            const SizedBox(height: 20),
            if (!isVoiceQuestion)
              Text(
                questions[currentIndex],
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            if (isVoiceQuestion)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _speak(questions[currentIndex]),
                    icon: const Icon(Icons.volume_up),
                    label: const Text("ฟังสถานการณ์"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showTextDialog(questions[currentIndex]),
                    icon: const Icon(Icons.chrome_reader_mode),
                    label: const Text("ดูข้อความ"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Text(
              // 🔹 เพิ่มคำถามข้อความ
              Sub_questions[currentIndex],
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ...options[currentIndex].map(
              (opt) => Align(
                alignment: Alignment.center, // จัดให้อยู่กลางแนวนอน
                child: Container(
                  width: 800, // ⬅️ ปรับตรงนี้ให้แคบลงตามต้องการ
                  child: Card(
                    color: _optionColor(opt),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: RadioListTile<String>(
                      title: Text(opt, style: const TextStyle(fontSize: 24)),
                      value: opt,
                      groupValue: userAnswers[currentIndex],
                      onChanged: (!answered && !isSubmitting)
                          ? (val) =>
                                setState(() => userAnswers[currentIndex] = val!)
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      visualDensity: const VisualDensity(
                        horizontal: -2,
                        vertical: -2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (answered)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isCorrect ? "✅ ตอบถูกต้อง!" : "❌ ยังไม่ถูกนะ",
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
                  horizontal: 40,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
