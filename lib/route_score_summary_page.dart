import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

// ✅ Model สำหรับใช้แสดงผลคะแนน
class RouteScoreSummaryDisplay {
  final int totalScore;
  final Map<String, int> chapterScores;

  RouteScoreSummaryDisplay({
    required this.totalScore,
    required this.chapterScores,
  });
}

class RouteScoreSummaryPage extends StatefulWidget {
  final String username;

  const RouteScoreSummaryPage({Key? key, required this.username}) : super(key: key);

  @override
  State<RouteScoreSummaryPage> createState() => _RouteScoreSummaryPageState();
}

class _RouteScoreSummaryPageState extends State<RouteScoreSummaryPage> {
  Map<int, RouteScoreSummaryDisplay> _routeSummaries = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRouteSummaries();
  }

  Future<void> _fetchRouteSummaries() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.API_BASE_URL}/get_score?username=${widget.username}'),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final rawSummaries = userData['route_summaries'] as Map<String, dynamic>;

        final parsedSummaries = <int, RouteScoreSummaryDisplay>{};
        rawSummaries.forEach((key, value) {
          final int routeId = int.parse(key);
          final chapterScores = (value['chapter_scores'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v as int),
          );
          parsedSummaries[routeId] = RouteScoreSummaryDisplay(
            totalScore: value['total_score'],
            chapterScores: chapterScores,
          );
        });

        setState(() {
          _routeSummaries = parsedSummaries;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'โหลดข้อมูลคะแนนไม่สำเร็จ';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int overallScore = _routeSummaries.values.fold(0, (sum, r) => sum + r.totalScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎉 สรุปคะแนนหลังจบเกม"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.indigo],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
                      const SizedBox(height: 16),
                      Text(
                        "คะแนนของ ${widget.username}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "คะแนนรวม: $overallScore",
                        style: const TextStyle(fontSize: 22, color: Colors.greenAccent),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _routeSummaries.length,
                          itemBuilder: (context, index) {
                            final routeId = _routeSummaries.keys.elementAt(index);
                            final summary = _routeSummaries[routeId]!;

                            final chapterList = summary.chapterScores.entries.toList()
                              ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "🚀 เส้นทางที่ $routeId",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text("คะแนนรวม: ${summary.totalScore} คะแนน"),
                                    const Divider(),
                                    const Text("คะแนนแต่ละบท:"),
                                    const SizedBox(height: 6),
                                    ...chapterList.map((e) => Text("• บทที่ ${e.key}: ${e.value} คะแนน")),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("กลับหน้าหลัก"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
