// lib/leaderboard_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart'; // Import AppConstants

class LeaderboardPage extends StatefulWidget {
  final String username;
  final String fullName; // Added fullName

  const LeaderboardPage({Key? key, required this.username, required this.fullName}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int? _selectedRouteId; // State variable for selected routeId (null means All Routes)

  Map<String, dynamic>? _currentUserRankEntry; // To store current user's rank data

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear error message before loading
      _currentUserRankEntry = null; // Clear current user rank data
    });

    try {
      String url = '${AppConstants.API_BASE_URL}/leaderboard';
      if (_selectedRouteId != null) {
        url += '?route_id=$_selectedRouteId'; // Add query parameter if a routeId is selected
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);

        List<Map<String, dynamic>> parsedData = [];

        // Check Backend response format
        if (responseBody is List) {
          parsedData = List<Map<String, dynamic>>.from(responseBody.map((item) {
            return {
              'username': item['username']?.toString() ?? 'ไม่ระบุชื่อผู้ใช้',
              'full_name': item['full_name']?.toString() ?? '', // Ensure full_name is parsed
              'score': (item['total_score'] is int) ? item['total_score'] : (int.tryParse(item['total_score']?.toString() ?? '0') ?? 0),
            };
          }));
        } else if (responseBody is Map && responseBody.containsKey('leaderboard') && responseBody['leaderboard'] is List) {
          parsedData = List<Map<String, dynamic>>.from(responseBody['leaderboard'].map((item) {
            return {
              'username': item['username']?.toString() ?? 'ไม่ระบุชื่อผู้ใช้',
              'full_name': item['full_name']?.toString() ?? '', // Ensure full_name is parsed
              'score': (item['total_score'] is int) ? item['total_score'] : (int.tryParse(item['total_score']?.toString() ?? '0') ?? 0),
            };
          }));
        } else if (responseBody is Map && responseBody.containsKey('message') && responseBody['message'] is String) {
          setState(() {
            _errorMessage = 'ข้อผิดพลาดจากเซิร์ฟเวอร์: ${responseBody['message']}';
          });
        } else {
          setState(() {
            _errorMessage = 'รูปแบบข้อมูลที่ได้รับจากเซิร์ฟเวอร์ไม่ถูกต้อง: ${response.body}';
          });
        }

        // Sort data by score in descending order
        parsedData.sort((a, b) => b['score'].compareTo(a['score']));

        // Calculate ranks with ties and find current user's rank
        List<Map<String, dynamic>> rankedData = [];
        int currentRank = 1;
        int? lastScore;
        bool foundCurrentUser = false;

        for (int i = 0; i < parsedData.length; i++) {
          final user = parsedData[i];
          final score = user['score'];

          if (lastScore != null && score == lastScore) {
            // Rank doesn't change for ties
          } else {
            currentRank = i + 1; // Rank is based on position if no tie, or first occurrence in a tie group
          }

          final Map<String, dynamic> userWithRank = {
            'rank': currentRank,
            'username': user['username'],
            'full_name': user['full_name'],
            'score': score,
          };
          rankedData.add(userWithRank);
          lastScore = score;

          // Find current user's rank
          if (user['username'] == widget.username) {
            _currentUserRankEntry = userWithRank;
            foundCurrentUser = true;
          }
        }

        // If current user was not found in the fetched data (e.g., score is 0 or less, not on leaderboard)
        if (!foundCurrentUser) {
          _currentUserRankEntry = {
            'rank': 0, // Indicate no rank
            'username': widget.username,
            'full_name': widget.fullName,
            'score': 0, // Explicitly show 0 score for unranked
            'unranked': true, // Custom flag to indicate unranked
          };
        }

        setState(() {
          _leaderboardData = rankedData;
        });

      } else {
        setState(() {
          _errorMessage = 'ไม่สามารถโหลดข้อมูลกระดานผู้นำได้: สถานะ ${response.statusCode} - ${response.body}';
          _leaderboardData = []; // Clear existing data
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${e.toString()}';
        _leaderboardData = []; // Clear existing data
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper widget for medal icons
  Widget _buildMedalIcon(int rank, {bool large = false}) {
    double size = large ? 38 : 28; // Slightly smaller large icon for better fit
    double radius = large ? 18 : 14; // Slightly smaller radius

    if (rank == 0) { // For "unranked"
      return CircleAvatar(
        backgroundColor: Colors.blueGrey.shade700,
        radius: radius,
        child: Icon(Icons.mood_bad, color: Colors.white, size: size * 0.7), // A bit smaller unhappy face
      );
    }
    
    switch (rank) {
      case 1:
        return Icon(Icons.emoji_events, color: Colors.amberAccent, size: size);
      case 2:
        return Icon(Icons.emoji_events, color: Colors.blueGrey.shade200, size: size); // Silver-ish
      case 3:
        return Icon(Icons.emoji_events, color: Colors.orange.shade700, size: size); // Bronze-ish
      default:
        return CircleAvatar(
          backgroundColor: Colors.blueAccent.shade700, // Darker blue for numbers
          radius: radius,
          child: Text(
            '$rank',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: large ? 16 : 13),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'กระดานผู้นำ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade800, // Deeper blue app bar
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<int?>(
              value: _selectedRouteId,
              hint: const Text('เลือกเส้นทาง', style: TextStyle(color: Colors.white70)),
              dropdownColor: Colors.blue.shade700, // Dropdown background
              style: const TextStyle(color: Colors.white, fontSize: 16),
              iconEnabledColor: Colors.white, // Dropdown arrow color
              items: <DropdownMenuItem<int?>>[
                const DropdownMenuItem<int?>(
                  value: null, // null for "All Routes"
                  child: Text('ทุกเส้นทาง'),
                ),
                for (int i = 1; i <= 3; i++) // Assuming 3 routes
                  DropdownMenuItem<int?>(
                    value: i,
                    child: Text('เส้นทางที่ $i'),
                  ),
              ],
              onChanged: (int? newValue) {
                setState(() {
                  _selectedRouteId = newValue;
                  _fetchLeaderboard(); // Load new data when route changes
                });
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white)) // Show loading spinner
            : _errorMessage.isNotEmpty // If there's an error message
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 50), // Error icon
                          const SizedBox(height: 10),
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _fetchLeaderboard, // Reload button
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('ลองใหม่'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _leaderboardData.isEmpty && _currentUserRankEntry?['unranked'] != true // If no leaderboard data and current user isn't just "unranked"
                    ? Center(
                        child: Text(
                          'ไม่มีข้อมูลกระดานผู้นำสำหรับ${_selectedRouteId == null ? 'ทุกเส้นทาง' : 'เส้นทางที่ $_selectedRouteId'} ในขณะนี้',
                          style: const TextStyle(color: Colors.white70, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'ผู้เล่นคะแนนสูงสุด',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightGreenAccent, // Greenish glow
                                  shadows: [
                                    Shadow(
                                        blurRadius: 8.0,
                                        color: Colors.black45,
                                        offset: Offset(2.0, 2.0))
                                  ]),
                            ),
                            const SizedBox(height: 20),
                            // Display current user's rank
                            if (_currentUserRankEntry != null)
                              Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 8, // Higher elevation to stand out
                                color: _currentUserRankEntry!['unranked'] == true
                                    ? Colors.blueGrey.shade800 // Darker grey for unranked
                                    : Colors.blue.shade700, // Deeper blue for ranked current user
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide(
                                        color: _currentUserRankEntry!['unranked'] == true
                                            ? Colors.blueGrey.shade600
                                            : Colors.blue.shade300, // Lighter blue border
                                        width: 2)),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'อันดับของคุณ:',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildMedalIcon(_currentUserRankEntry!['rank'] as int, large: true),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Text(
                                              _currentUserRankEntry!['full_name'].isNotEmpty
                                                  ? _currentUserRankEntry!['full_name']
                                                  : _currentUserRankEntry!['username'] ?? 'Unknown User', // Prioritize full name
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          _currentUserRankEntry!['unranked'] == true
                                              ? const Text(
                                                  'ไร้อันดับ',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white), // White for "Unranked" text
                                                )
                                              : Text(
                                                  '${_currentUserRankEntry!['score']} คะแนน',
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.lightGreenAccent), // Score in bright green
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10), // Spacing after current user's rank

                            Expanded(
                              child: ListView.builder(
                                itemCount: _leaderboardData.length,
                                itemBuilder: (context, index) {
                                  final user = _leaderboardData[index];
                                  final int rank = user['rank'];

                                  // Hide the current user's entry in the main list if displayed as a separate card
                                  if (_currentUserRankEntry != null && user['username'] == widget.username && _currentUserRankEntry!['unranked'] != true) {
                                    return const SizedBox.shrink(); // Hide this item if ranked and shown above
                                  }
                                  // Also hide if current user is unranked and we've already shown their "unranked" card
                                  if (_currentUserRankEntry != null && user['username'] == widget.username && _currentUserRankEntry!['unranked'] == true) {
                                    return const SizedBox.shrink();
                                  }


                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                    elevation: 4,
                                    color: Colors.blue.shade600, // Card background for list items
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          _buildMedalIcon(rank), // Use helper for medal/rank
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user['full_name'].isNotEmpty
                                                      ? user['full_name']
                                                      : user['username'] ?? 'Unknown', // Show full_name first, then username
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white),
                                                ),
                                                if (user['full_name'].isNotEmpty && user['full_name'] != user['username']) // If full_name exists and is different from username
                                                  Text(
                                                    '(${user['username']})', // Show username in smaller parentheses
                                                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${user['score'] ?? 0} คะแนน',
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.lightGreenAccent),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Go back to WelcomePage
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade600, // Button color
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 5,
                                shadowColor: Colors.black54,
                              ),
                              child: const Text('กลับหน้าหลัก'),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}