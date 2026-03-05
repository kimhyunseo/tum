import 'package:flutter/material.dart';
import 'home_page.dart';
import 'record_page.dart';
import 'stats_page.dart';
import 'goal_page.dart';
import 'settings_page.dart';

class TumRootPage extends StatefulWidget {
  const TumRootPage({super.key});

  @override
  State<TumRootPage> createState() => _TumRootPageState();
}

class _TumRootPageState extends State<TumRootPage> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    RecordPage(),
    StatsPage(),
    GoalPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '기록'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: '목표'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
