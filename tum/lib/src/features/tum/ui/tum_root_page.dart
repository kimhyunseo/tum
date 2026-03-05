import 'package:flutter/material.dart';
import '../../wishlist/receive_share_service.dart';
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
  final ReceiveShareService _shareService = ReceiveShareService();

  final _pages = const [
    HomePage(),
    RecordPage(),
    StatsPage(),
    GoalPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _shareService.startListening(context);
  }

  @override
  void dispose() {
    _shareService.dispose();
    super.dispose();
  }

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
