// lib/comments_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart'; // นำเข้า AppConstants

class CommentsPage extends StatefulWidget {
  final String username;

  CommentsPage({required this.username});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> _comments = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.API_BASE_URL}/get_comments'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _comments = data['comments'] ?? [];
        });
      } else {
        setState(() {
          _errorMessage = 'ไม่สามารถดึงความคิดเห็นได้: ${jsonDecode(response.body)['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'กรุณาพิมพ์ความคิดเห็นก่อนส่ง';
        _successMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/add_comment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'comment_text': _commentController.text,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _successMessage = 'ส่งความคิดเห็นสำเร็จ!';
          _commentController.clear();
        });
        _fetchComments(); // โหลดความคิดเห็นใหม่
      } else {
        setState(() {
          _errorMessage = 'ส่งความคิดเห็นไม่สำเร็จ: ${jsonDecode(response.body)['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ความคิดเห็น'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ความคิดเห็นของคุณที่นี่...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitComment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('ส่งความคิดเห็น'),
                        ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _successMessage,
                        style: const TextStyle(color: Colors.green),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading && _comments.isEmpty // แสดง loading ถ้ายังไม่มีข้อมูล
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty && _comments.isEmpty // แสดง error ถ้าโหลดไม่ได้และไม่มีข้อมูล
                      ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                      : _comments.isEmpty
                          ? const Center(child: Text('ยังไม่มีความคิดเห็น'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                final timestamp = DateTime.parse(comment['created_at']);
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['username'] ?? 'Unknown User',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          comment['comment_text'] ?? '',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${timestamp.toLocal().day}/${timestamp.toLocal().month}/${timestamp.toLocal().year} ${timestamp.toLocal().hour}:${timestamp.toLocal().minute}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
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
    );
  }
}
