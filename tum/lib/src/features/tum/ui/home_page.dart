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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          const Text('지출 요약', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _summaryCard(
            title: '이번 달 지출',
            value: '${totalSpent.toStringAsFixed(0)}원',
            subtitle: '목표: ${goal.monthlyLimit}원',
            color: const Color(0xFFC8E6C9),
          ),
          const SizedBox(height: 12),
          _summaryCard(
            title: '생각 중인 항목',
            value: '${thinking.length}건',
            subtitle: '총 ${records.length}건의 시도',
            color: const Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 24),
          const Text('오늘 생각 중인 목록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (thinking.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('지금은 비어있어요. 새로운 생각을 시작해볼까요?')),
              ),
            ),
          for (final r in thinking)
            _thinkingItemCard(r),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PurchaseAttemptPage()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('구매 생각 시작하기'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LinkInputPage()),
            ),
            icon: const Icon(Icons.link),
            label: const Text('링크로 빠르게 추가'),
          )
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Color(0xFF388E3C))),
          ],
        ),
      ),
    );
  }

  Widget _thinkingItemCard(PurchaseRecord r) {
    final days = _daysLeft(r.thinkUntil);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF81C784),
          child: Text(days.toString(), style: const TextStyle(color: Colors.white)),
        ),
        title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('D-$days일 | ${r.category}'),
        trailing: const Icon(Icons.chevron_right),
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
