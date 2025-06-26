// lib/character_selection_page.dart
import 'package:flutter/material.dart';
import 'route_selection_page.dart'; // นำเข้าหน้าเลือกเส้นทาง

class CharacterSelectionPage extends StatelessWidget {
  final String username;
  final String fullName;
  final int currentChapter;
  final int currentRouteId; // เพิ่ม: เพื่อส่งผ่านค่า current_route_id

  CharacterSelectionPage({
    required this.username,
    required this.fullName,
    required this.currentChapter,
    required this.currentRouteId,
  });

  @override
  Widget build(BuildContext context) {
    // ข้อมูลตัวละครจำลอง
    final List<Map<String, String>> characters = [
      {
        'name': 'Ava',
        'image': 'assets/images/buddy_8.png',
        'description': 'นักเรียนที่อยากเรียนรู้เกี่ยวกับอันตรายของบุหรี่ไฟฟ้า',
      },
      {
        'name': 'Ben',
        'image': 'assets/images/buddy_8.png', // ใช้รูปเดิมไปก่อน
        'description': 'นักกีฬาที่ต้องการหลีกเลี่ยงการสูบบุหรี่ไฟฟ้า',
      },
      {
        'name': 'Chloe',
        'image': 'assets/images/buddy_8.png', // ใช้รูปเดิมไปก่อน
        'description': 'ศิลปินที่ต้องการสร้างสรรค์ผลงานโดยไม่พึ่งนิโคติน',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกตัวละครของคุณ'),
        automaticallyImplyLeading: false, // ซ่อนปุ่มย้อนกลับ
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'เลือกตัวละครเพื่อเริ่มการผจญภัย!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 20, // ระยะห่างระหว่างการ์ดแนวนอน
                runSpacing: 20, // ระยะห่างระหว่างการ์ดแนวตั้ง
                alignment: WrapAlignment.center,
                children: characters.map((character) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: InkWell(
                      onTap: () {
                        // เมื่อเลือกตัวละคร ให้นำทางไปยังหน้าเลือกเส้นทาง
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RouteSelectionPage(
                              username: username,
                              fullName: fullName,
                              currentChapter: currentChapter,
                              currentRouteId: currentRouteId, // ส่งค่า route id
                              selectedCharacterName: character['name']!, // ส่งชื่อตัวละครที่เลือก
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 250, // กำหนดความกว้างของการ์ด
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RouteSelectionPage(
                                      username: username,
                                      fullName: fullName,
                                      currentChapter: currentChapter,
                                      currentRouteId: currentRouteId,
                                      selectedCharacterName: character['name']!,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('เลือกตัวละครนี้'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('กลับหน้าหลัก'),
                onPressed: () {
                  Navigator.pop(context); // กลับไปยัง WelcomePage
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
