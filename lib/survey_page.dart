// lib/survey_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart'; // นำเข้า AppConstants

class SurveyPage extends StatefulWidget {
  final String username; // เพิ่ม username เพื่อส่งไปกับข้อมูลแบบประเมิน
  const SurveyPage({Key? key, required this.username}) : super(key: key);

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  // --- ส่วนที่ 1: ข้อมูลทั่วไปของผู้ตอบแบบสอบถาม ---
  String? _selectedGender; // เพศ
  String? _selectedSchoolLevel; // ระดับชั้น
  bool? _hasPlayedHealthGames; // เคยเล่นเกมที่เกี่ยวข้องกับสุขภาพหรือไม่

  // --- ส่วนที่ 2: ความพึงพอใจต่อกิจกรรมในรูปแบบเกม (คะแนน 1-5) ---
  // Key: ลำดับรายการประเมิน (เช่น 1, 2, ...), Value: คะแนนที่เลือก (1-5)
  final Map<int, int?> _satisfactionScores = {
    1: null, 2: null, 3: null, 4: null, 5: null,
    6: null, 7: null, 8: null, 9: null, 10: null,
  };

  final List<String> _satisfactionQuestions = [
    'เกมมีความสนุก น่าสนใจ',
    'กราฟิก / ภาพ / เสียงของเกมดึงดูดใจ',
    'เนื้อหาที่นำเสนอในเกมเข้าใจง่าย',
    'เกมช่วยให้ตระหนักถึงโทษของบุหรี่ไฟฟ้า',
    'เกมส่งเสริมการคิดวิเคราะห์เกี่ยวกับพฤติกรรมเสี่ยง',
    'เกมช่วยเพิ่มความรู้เกี่ยวกับการป้องกันตนเองจากบุหรี่ไฟฟ้า',
    'สามารถนำสิ่งที่เรียนรู้จากเกมไปใช้ในชีวิตจริงได้',
    'ระยะเวลาในการเล่นเกมเหมาะสม',
    'ระบบการให้คะแนน/รางวัลในเกมกระตุ้นให้เล่นต่อ',
    'โดยรวมพึงพอใจต่อเกมนี้',
  ];

  // --- ส่วนที่ 3: ความคิดเห็นหลังการเล่นเกม (ตอบได้มากกว่า 1 ข้อ) ---
  final Map<String, bool> _postGameFeelings = {
    'ฉันรู้จักโทษของบุหรี่ไฟฟ้ามากขึ้น': false,
    'ฉันมีความตั้งใจที่จะไม่ลองสูบบุหรี่ไฟฟ้า': false,
    'ฉันสามารถอธิบายให้เพื่อนฟังถึงอันตรายของบุหรี่ไฟฟ้าได้': false,
    'ฉันรู้วิธีปฏิเสธหรือหลีกเลี่ยงสถานการณ์ที่เสี่ยง': false,
    'ฉันอยากให้เพื่อน ๆ ได้เล่นเกมนี้ด้วย': false,
  };
  final TextEditingController _otherFeelingController = TextEditingController(); // สำหรับ "อื่น ๆ (ระบุ)"

  // --- ส่วนที่ 4: ข้อเสนอแนะเพิ่มเติม ---
  final TextEditingController _suggestionController = TextEditingController();

  bool _isSubmitting = false;
  String _submissionMessage = '';

  // Function to handle submission of the satisfaction survey
  Future<void> _submitSatisfactionSurvey() async {
    // Basic validation
    if (_selectedGender == null || _selectedSchoolLevel == null || _hasPlayedHealthGames == null) {
      setState(() {
        _submissionMessage = 'กรุณากรอกข้อมูลส่วนที่ 1 ให้ครบถ้วน';
      });
      return;
    }

    if (_satisfactionScores.values.any((score) => score == null)) {
      setState(() {
        _submissionMessage = 'กรุณาให้คะแนนความพึงพอใจทุกข้อในส่วนที่ 2';
      });
      return;
    }

    // Prepare data for submission
    Map<String, dynamic> surveyData = {
      'username': widget.username,
      'gender': _selectedGender,
      'school_level': _selectedSchoolLevel,
      'has_played_health_games': _hasPlayedHealthGames,
      'satisfaction_scores': _satisfactionScores.map((key, value) => MapEntry(key.toString(), value)), // Convert int keys to String
      'post_game_feelings': _postGameFeelings,
      'other_feeling_text': _otherFeelingController.text.trim(),
      'suggestions': _suggestionController.text.trim(),
    };

    setState(() {
      _isSubmitting = true;
      _submissionMessage = 'กำลังส่งแบบประเมิน...';
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/submit_satisfaction_survey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(surveyData),
      );

      if (response.statusCode == 201) {
        setState(() {
          _submissionMessage = 'ส่งแบบประเมินสำเร็จ! ขอบคุณสำหรับความคิดเห็น';
        });
        // Clear form (optional)
        _clearForm();
      } else {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _submissionMessage = 'เกิดข้อผิดพลาดในการส่งแบบประเมิน: ${responseBody['message'] ?? 'ไม่ทราบข้อผิดพลาด'}';
        });
      }
    } catch (e) {
      setState(() {
        _submissionMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _clearForm() {
    setState(() {
      _selectedGender = null;
      _selectedSchoolLevel = null;
      _hasPlayedHealthGames = null;
      _satisfactionScores.updateAll((key, value) => null);
      _postGameFeelings.updateAll((key, value) => false);
      _otherFeelingController.clear();
      _suggestionController.clear();
    });
  }

  @override
  void dispose() {
    _otherFeelingController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แบบประเมินความพึงพอใจ'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ส่วนที่ 1: ข้อมูลทั่วไปของผู้ตอบแบบสอบถาม',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),

                      // 1. เพศ
                      const Text('1. เพศ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('ชาย'),
                            value: 'ชาย',
                            groupValue: _selectedGender,
                            onChanged: (value) => setState(() => _selectedGender = value),
                          ),
                          RadioListTile<String>(
                            title: const Text('หญิง'),
                            value: 'หญิง',
                            groupValue: _selectedGender,
                            onChanged: (value) => setState(() => _selectedGender = value),
                          ),
                          RadioListTile<String>(
                            title: const Text('อื่น ๆ'),
                            value: 'อื่น ๆ',
                            groupValue: _selectedGender,
                            onChanged: (value) => setState(() => _selectedGender = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 2. ระดับชั้น
                      const Text('2. ระดับชั้น', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('ม.1'),
                            value: 'ม.1',
                            groupValue: _selectedSchoolLevel,
                            onChanged: (value) => setState(() => _selectedSchoolLevel = value),
                          ),
                          RadioListTile<String>(
                            title: const Text('ม.2'),
                            value: 'ม.2',
                            groupValue: _selectedSchoolLevel,
                            onChanged: (value) => setState(() => _selectedSchoolLevel = value),
                          ),
                          RadioListTile<String>(
                            title: const Text('ม.3'),
                            value: 'ม.3',
                            groupValue: _selectedSchoolLevel,
                            onChanged: (value) => setState(() => _selectedSchoolLevel = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 3. เคยเล่นเกมที่เกี่ยวข้องกับสุขภาพหรือไม่?
                      const Text('3. เคยเล่นเกมที่เกี่ยวข้องกับสุขภาพหรือไม่?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Column(
                        children: [
                          RadioListTile<bool>(
                            title: const Text('เคย'),
                            value: true,
                            groupValue: _hasPlayedHealthGames,
                            onChanged: (value) => setState(() => _hasPlayedHealthGames = value),
                          ),
                          RadioListTile<bool>(
                            title: const Text('ไม่เคย'),
                            value: false,
                            groupValue: _hasPlayedHealthGames,
                            onChanged: (value) => setState(() => _hasPlayedHealthGames = value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10), // Space after section 1 card

              Card(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ส่วนที่ 2: ความพึงพอใจต่อกิจกรรมในรูปแบบเกม',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '(1=ไม่พึงพอใจเลย / 2=ไม่พึงพอใจ / 3=ปานกลาง / 4=พึงพอใจ / 5=พึงพอใจมาก)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 15),

                      // ตารางคะแนนความพึงพอใจ
                      // ใช้ Column แทน ListView.builder เพื่อแก้ปัญหา RenderBox
                      Column(
                        children: List.generate(_satisfactionQuestions.length, (index) {
                          final qIndex = index + 1; // ลำดับคำถาม (1-10)
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${qIndex}. ${_satisfactionQuestions[index]}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  // **MODIFICATION START**
                                  // Replace SingleChildScrollView and Row with a more robust layout for radio buttons
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Calculate available width for each radio button
                                      // This ensures they scale correctly within the available space
                                      double itemWidth = constraints.maxWidth / 5;
                                      // Ensure a minimum width to prevent collapse
                                      if (itemWidth < 60) itemWidth = 60; // Or adjust as needed

                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: List.generate(5, (scoreIndex) {
                                          final scoreValue = scoreIndex + 1;
                                          return SizedBox(
                                            width: itemWidth,
                                            child: RadioListTile<int>(
                                              title: Text('$scoreValue', style: const TextStyle(fontSize: 14)),
                                              value: scoreValue,
                                              groupValue: _satisfactionScores[qIndex],
                                              onChanged: (value) {
                                                setState(() {
                                                  _satisfactionScores[qIndex] = value;
                                                });
                                              },
                                              visualDensity: VisualDensity.compact, // Make radio buttons more compact
                                            ),
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                  // **MODIFICATION END**
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10), // Space after section 2 card

              Card(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ส่วนที่ 3: ความคิดเห็นหลังการเล่นเกม',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '(ตอบได้มากกว่า 1 ข้อ)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 15),
                      // ใช้ Column แทน ListView.builder
                      Column(
                        children: _postGameFeelings.keys.map((String feeling) {
                          return CheckboxListTile(
                            title: Text(feeling),
                            value: _postGameFeelings[feeling],
                            onChanged: (bool? value) {
                              setState(() {
                                _postGameFeelings[feeling] = value!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _otherFeelingController,
                          decoration: const InputDecoration(
                            hintText: 'อื่น ๆ (ระบุ)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10), // Space after section 3 card

              Card(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ส่วนที่ 4: ข้อเสนอแนะเพิ่มเติม',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _suggestionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'โปรดแสดงความคิดเห็นหรือเสนอแนวทางในการปรับปรุงเกมนี้ให้ดียิ่งขึ้น:',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30), // Space after section 4 card

              Center(
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitSatisfactionSurvey,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ส่งแบบประเมิน'),
                      ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _submissionMessage,
                  style: TextStyle(
                    color: _submissionMessage.contains('สำเร็จ') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // กลับไปยังหน้า WelcomePage
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('กลับหน้าหลัก'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}