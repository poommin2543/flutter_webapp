// lib/register_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _fullName = TextEditingController();
  final _age = TextEditingController();
  final _school = TextEditingController();
  final _schoolLevel = TextEditingController();

  String _status = 'Teacher';
  bool _loading = false;
  String _message = '';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final resp = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _username.text.trim(),
          'password': _password.text,
          'full_name': _fullName.text.trim(),
          'old': int.parse(_age.text),
          'school': _school.text.trim(),
          'status': _status,
          'school_level': _status == 'Student' ? _schoolLevel.text.trim() : '',
        }),
      );
      final body = jsonDecode(resp.body);
      setState(() {
        _message = resp.statusCode == 201
            ? 'ลงทะเบียนสำเร็จ!'
            : 'ลงทะเบียนล้มเหลว: ${body['message'] ?? resp.statusCode}';
      });
      if (resp.statusCode == 201) {
        Future.delayed(Duration(seconds: 3), () => Navigator.pop(context));
      }
    } catch (e) {
      setState(() => _message = 'เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _fullName.dispose();
    _age.dispose();
    _school.dispose();
    _schoolLevel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ลงทะเบียนเพื่อเข้าใช้บริการ')),
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 1.0),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset(
                'assets/images/login2.png',
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildField(
                          _username,
                          'Username (ชื่อผู้ใช้งาน, กรอกเป็นภาษาอังกฤษหรือตัวเลขเท่านั้น)',
                          validator: (v) =>
                              v!.isEmpty ? 'กรุณากรอกชื่อผู้ใช้งาน' : null,
                        ),
                        _buildPasswordField(
                          controller: _password,
                          label:
                              'Password (รหัสผ่าน, ตัวอักษรภาษาอังกฤษหรือตัวเลขจำนวน 8 ตัวขึ้นไป)',
                          obscure: _obscurePassword,
                          toggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          validator: (v) => v!.length < 8
                              ? 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร'
                              : null,
                        ),
                        _buildPasswordField(
                          controller: _confirmPassword,
                          label: 'Confirm Password (ยืนยันรหัสผ่าน)',
                          obscure: _obscureConfirm,
                          toggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          validator: (v) =>
                              v != _password.text ? 'รหัสผ่านไม่ตรงกัน' : null,
                        ),
                        _buildField(
                          _fullName,
                          'Full Name (ชื่อ-สกุล, กรอกได้ทั้งภาษาไทยและภาษาอังกฤษ)',
                          validator: (v) =>
                              v!.isEmpty ? 'กรุณากรอกชื่อ-สกุล' : null,
                        ),
                        _buildField(
                          _age,
                          'Age (อายุ)',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v!);
                            if (n == null || n < 6 || n > 99)
                              return 'กรุณากรอกอายุที่ถูกต้อง';
                            return null;
                          },
                        ),
                        _buildField(
                          _school,
                          'School (โรงเรียน, กรอกได้ทั้งภาษาไทยและภาษาอังกฤษ)',
                          validator: (v) =>
                              v!.isEmpty ? 'กรุณากรอกโรงเรียน' : null,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text('สถานะ: ', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _status,
                                items: ['Teacher', 'Student', 'อื่นๆ']
                                    .map(
                                      (e) => DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(
                                          e == 'Teacher'
                                              ? 'ครู'
                                              : e == 'Student'
                                              ? 'นักเรียน'
                                              : 'อื่นๆ',
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() {
                                  _status = v!;
                                  if (_status == 'Teacher' ||
                                      _status == 'Student') {
                                    _schoolLevel.clear();
                                  }
                                }),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        if (_status == 'Student' || _status == 'อื่นๆ')
                          _buildField(
                            _schoolLevel,
                            _status == 'Student'
                                ? 'School Level (ระดับชั้น, เช่น ม.3/4)'
                                : 'กรุณาระบุสถานะเพิ่มเติม',
                            validator: (v) =>
                                v!.isEmpty ? 'กรุณากรอกข้อมูลเพิ่มเติม' : null,
                          ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _loading ? null : _register,
                          child: _loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'สมัครสมาชิก',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                        if (_message.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              _message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: _message.contains('สำเร็จ')
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctl,
    String label, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctl,
        keyboardType: keyboardType,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }
}
