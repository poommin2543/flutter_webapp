import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main.dart'; // สำหรับ logout แล้วกลับไป LoginPage
import 'chapter1.dart';
// import 'chapter2.dart';
// import 'chapter3.dart';
// import 'chapter4.dart';
// import 'chapter5.dart';

class MainPage extends StatefulWidget {
  final String fullName;
  final String username;
  final int currentUnlockedChapter;

  MainPage({
    required this.fullName,
    required this.username,
    required this.currentUnlockedChapter,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int totalScore = 0;
  late int currentUnlockedChapter;
  Map<int, int> chapterScores = {};

  @override
  void initState() {
    super.initState();
    currentUnlockedChapter = widget.currentUnlockedChapter;
    loadScores();
  }

  Future<void> loadScores() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8080/get_score?username=${widget.username}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        totalScore = data['total_score'];
        final Map<String, dynamic> raw = data['chapter_score'];
        chapterScores = raw.map(
          (key, value) => MapEntry(int.parse(key), value),
        );

        //  ดึง current chapter ที่ปลดล็อกจาก backend
        currentUnlockedChapter = data['current_chapter'];
      });
    }
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void navigateToChapter(int index) {
    final chapterNumber = index + 1;
    Widget chapterPage;

    switch (index) {
      case 0:
        chapterPage = Chapter1Page(
          chapter: chapterNumber,
          username: widget.username,
          onFinished: loadScores,
        );
      //   break;
    //   case 1:
    //     chapterPage = Chapter2Page(
    //       chapter: chapterNumber,
    //       username: widget.username,
    //       onFinished: loadScores,
    //     );
    //     break;
    //   case 2:
    //     chapterPage = Chapter3Page(
    //       chapter: chapterNumber,
    //       username: widget.username,
    //       onFinished: loadScores,
    //     );
    //     break;
    //   case 3:
    //     chapterPage = Chapter4Page(
    //       chapter: chapterNumber,
    //       username: widget.username,
    //       onFinished: loadScores,
    //     );
    //     break;
    //   case 4:
    //     chapterPage = Chapter5Page(
    //       chapter: chapterNumber,
    //       username: widget.username,
    //       onFinished: loadScores,
    //     );
    //     break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => chapterPage),
    ).then((_) {
      loadScores(); // ✅ โหลดคะแนนและ current chapter ใหม่
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Chapter'),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Center(child: Text('Hi, ${widget.fullName}')),
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Score: $totalScore", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            ...chapterScores.entries.map(
              (e) => Text('Chapter ${e.key}: ${e.value} คะแนน'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  final chapterNumber = index + 1;
                  final isUnlocked = chapterNumber <= currentUnlockedChapter;

                  return ListTile(
                    title: Text('Chapter $chapterNumber'),
                    trailing: isUnlocked
                        ? Icon(Icons.arrow_forward_ios)
                        : Icon(Icons.lock),
                    enabled: isUnlocked,
                    onTap: isUnlocked
                        ? () => navigateToChapter(index)
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please complete previous chapters first.',
                                ),
                              ),
                            );
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
