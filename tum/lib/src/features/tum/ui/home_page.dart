import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/purchase_record_provider.dart';
import '../providers/budget_goal_provider.dart';
import 'purchase_attempt_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(purchaseRecordProvider);
    final goal = ref.watch(budgetGoalProvider);
    final totalSpent = records
        .where((r) => r.status == 'bought')
        .fold<double>(0, (sum, r) => sum + r.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('T.U.M')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘의 구매 기록: ${records.length}건'),
            const SizedBox(height: 8),
            Text('이번 달 사용 합계: ${totalSpent.toStringAsFixed(0)}원'),
            const SizedBox(height: 8),
            Text('목표(주/월): ${goal.weeklyLimit} / ${goal.monthlyLimit}'),
            const SizedBox(height: 24),
            const Text('오늘의 제안: 구매 전에 5분만 더 생각해봐요'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PurchaseAttemptPage()),
              ),
              child: const Text('구매 생각 시작하기'),
            )
          ],
        ),
      ),
    );
  }
}
