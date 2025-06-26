    // lib/survey_page.dart
    import 'package:flutter/material.dart';

    class SurveyPage extends StatefulWidget {
      const SurveyPage({Key? key}) : super(key: key);

      @override
      State<SurveyPage> createState() => _SurveyPageState();
    }

    class _SurveyPageState extends State<SurveyPage> {
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('แบบสำรวจ'),
          ),
          body: const Center(
            child: Text(
              'หน้านี้สำหรับแบบสำรวจของคุณ',
              style: TextStyle(fontSize: 24),
            ),
          ),
        );
      }
    }
    