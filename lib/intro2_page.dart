import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'chapter2.dart';

class Chapter2IntroPage extends StatefulWidget {
  final int chapter;
  final String username;
  final VoidCallback onFinished;

  Chapter2IntroPage({
    required this.chapter,
    required this.username,
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
      videoId: 'c0Yh0qMjw0Y',
      params: YoutubePlayerParams(
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
      appBar: AppBar(title: Text('บทเรียน'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 500,
              child: YoutubePlayer(controller: _introController),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chapter2Page(
                      username: widget.username,
                      onFinished: widget.onFinished,
                      chapter: 2,
                    ),
                  ),
                );
              },
              child: Text('ต่อไป: ประเมินความรู้ความเข้าใจ'),
            ),
          ],
        ),
      ),
    );
  }
}
