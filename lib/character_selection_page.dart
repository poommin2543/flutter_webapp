// lib/character_selection_page.dart
import 'package:flutter/material.dart';
import 'route_selection_page.dart';

class CharacterSelectionPage extends StatelessWidget {
  final String username;
  final String fullName;
  final int currentChapter;
  final int currentRouteID;

  CharacterSelectionPage({
    required this.username,
    required this.fullName,
    required this.currentChapter,
    required this.currentRouteID,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> characters = [
      {
        'name': 'Ava',
        'image': 'assets/images/buddy_2.png',
        'description': 'นักเรียนที่อยากเรียนรู้เกี่ยวกับอันตรายของบุหรี่ไฟฟ้า',
        'available': false,
      },
      {
        'name': 'Ben',
        'image': 'assets/images/buddy_8.png',
        'description': 'นักกีฬาที่ต้องการหลีกเลี่ยงการสูบบุหรี่ไฟฟ้า',
        'available': true,
      },
      {
        'name': 'Chloe',
        'image': 'assets/images/buddy_5.png',
        'description': 'ศิลปินที่ต้องการสร้างสรรค์ผลงานโดยไม่พึ่งนิโคติน',
        'available': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกตัวละครของคุณ'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'เลือกตัวละครเพื่อเริ่มการผจญภัย!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: characters.map((character) {
                  final bool available = character['available'] as bool;
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: available ? 1.0 : 0.5,
                          child: Container(
                            width: 250,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  character['image']!,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  character['name']!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  character['description']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: available
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RouteSelectionPage(
                                                    username: username,
                                                    fullName: fullName,
                                                    currentChapter:
                                                        currentChapter,
                                                    currentRouteID:
                                                        currentRouteID,
                                                    selectedCharacterName:
                                                        character['name']!,
                                                  ),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: const Text('เลือกตัวละครนี้'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!available)
                          Positioned.fill(
                            child: Container(
                              color: Colors.white.withOpacity(0.6),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.lock,
                                      size: 50,
                                      color: Colors.redAccent,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Coming Soon',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('กลับหน้าหลัก'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
