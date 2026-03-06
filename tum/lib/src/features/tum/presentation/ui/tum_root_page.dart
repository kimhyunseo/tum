import 'package:flutter/material.dart';
import 'package:tum/src/features/wishlist/receive_share_service.dart';
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

import 'package:tum/src/core/theme/app_colors.dart';
import 'purchase_attempt_page.dart';
import 'link_import_page.dart';

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
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, '홈', 0),
            _navItem(Icons.history_rounded, '기록', 1),
            const SizedBox(width: 48), // FAB 공간
            _navItem(Icons.bar_chart_rounded, '통계', 2),
            _navItem(Icons.settings_rounded, '설정', 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int targetIndex) {
    final isSelected = _index == targetIndex;
    return InkWell(
      onTap: () => setState(() => _index = targetIndex),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppColors.primary : Colors.grey)),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('새로운 고민 시작하기', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _addOptionTile(
                context,
                title: '직접 입력하기',
                subtitle: '상품 이름과 가격을 직접 입력합니다',
                icon: Icons.edit_note_rounded,
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseAttemptPage()));
                },
              ),
              const SizedBox(height: 12),
              _addOptionTile(
                context,
                title: '링크 붙여넣기',
                subtitle: '상품 링크를 분석해 자동으로 입력합니다',
                icon: Icons.link_rounded,
                color: AppColors.savings,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkInputPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addOptionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
