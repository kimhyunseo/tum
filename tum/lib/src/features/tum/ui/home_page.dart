import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/purchase_record_provider.dart';
import '../providers/budget_goal_provider.dart';
import 'purchase_attempt_page.dart';
import 'link_import_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final Set<String> _shownDecision = {};

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(purchaseRecordProvider);
    final goal = ref.watch(budgetGoalProvider);
    final totalSpent = records
        .where((r) => r.status == 'bought')
        .fold<double>(0, (sum, r) => sum + r.amount);

    final thinking = records.where((r) => r.status == 'thinking').toList();
    final due = thinking
        .where((r) => r.thinkUntil != null && r.thinkUntil!.isBefore(DateTime.now()))
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final r in due) {
        if (_shownDecision.contains(r.id)) continue;
        _shownDecision.add(r.id);
        _showDecisionDialog(r.id, r.title);
        break;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('T.U.M')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryCard(
            title: '이번 달 지출',
            value: '${totalSpent.toStringAsFixed(0)}원',
            subtitle: '목표(주/월): ${goal.weeklyLimit} / ${goal.monthlyLimit}',
          ),
          const SizedBox(height: 12),
          _summaryCard(
            title: '오늘의 구매 기록',
            value: '${records.length}건',
            subtitle: '생각 중 ${thinking.length}건',
          ),
          const SizedBox(height: 16),
          const Text('오늘 생각 중인 목록', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (thinking.isEmpty)
            const Text('생각 중인 항목이 없습니다.'),
          for (final r in thinking)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(r.title),
              subtitle: Text('남은 기간: ${_daysLeft(r.thinkUntil)}일'),
              trailing: Text(r.category),
            ),
          const SizedBox(height: 16),
          const Text('오늘의 제안: 구매 전에 5분만 더 생각해봐요'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PurchaseAttemptPage()),
            ),
            child: const Text('구매 생각 시작하기'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LinkInputPage()),
            ),
            child: const Text('링크로 빠르게 추가'),
          )
        ],
      ),
    );
  }

  Widget _summaryCard({required String title, required String value, required String subtitle}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
      ),
    );
  }

  int _daysLeft(DateTime? target) {
    if (target == null) return 0;
    final diff = target.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  Future<void> _showDecisionDialog(String id, String title) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('구매 결정'),
        content: Text('"$title" 구매할까요?'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(purchaseRecordProvider.notifier).updateStatus(id, 'skipped');
              Navigator.pop(context);
            },
            child: const Text('안 함'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(purchaseRecordProvider.notifier).updateStatus(id, 'bought');
              Navigator.pop(context);
            },
            child: const Text('구매'),
          ),
        ],
      ),
    );
  }
}
