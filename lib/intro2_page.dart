// lib/intro2_page.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'chapter2.dart';

class Chapter2IntroPage extends StatefulWidget {
  final int chapter;
  final String username;
  final int routeId; // เพิ่ม: รับ routeId เข้ามา
  final VoidCallback onFinished;

  Chapter2IntroPage({
    required this.chapter,
    required this.username,
    required this.routeId, // กำหนดให้รับ routeId
    required this.onFinished,
  });

  @override
  _Chapter2IntroPageState createState() => _Chapter2IntroPageState();
}

class _Chapter2IntroPageState extends State<Chapter2IntroPage> {
  late YoutubePlayerController _introController;

  @override
  void initState() {
    super.initState();
    _introController = YoutubePlayerController.fromVideoId(
      videoId: 'c0Yh0qMjw0Y', // วิดีโอแนะนำบทที่ 2
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
      ),
    );
  }

  @override
  void dispose() {
    _introController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บทเรียนบทที่ 2'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 400, // ปรับความสูงให้เหมาะสมกับหน้าจอ
              child: YoutubePlayer(controller: _introController),
            ),
            const SizedBox(height: 20),
            const Text(
              'บทเรียนนี้จะช่วยประเมินความรู้ความเข้าใจเกี่ยวกับบุหรี่ไฟฟ้า',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chapter2Page(
                      username: widget.username,
                      onFinished: widget.onFinished,
                      chapter: 2,
                      routeId: widget.routeId, // ส่ง routeId
                    ),
                  ),
                );
              },
              child: const Text('ต่อไป: เริ่มบทที่ 2'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('กลับหน้าเลือกเส้นทาง'),
              onPressed: () {
                Navigator.pop(context); // กลับไปยังหน้าเลือกเส้นทาง
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
