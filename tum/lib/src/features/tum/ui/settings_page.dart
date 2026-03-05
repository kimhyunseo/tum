import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('알림 빈도/시간은 추후 커스터마이징 예정'),
            SizedBox(height: 8),
            Text('충동 지름 위험 카테고리는 추후 추가 예정'),
          ],
        ),
      ),
    );
  }
}
