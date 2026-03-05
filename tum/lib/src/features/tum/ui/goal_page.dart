import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_goal_provider.dart';

class GoalPage extends ConsumerStatefulWidget {
  const GoalPage({super.key});

  @override
  ConsumerState<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends ConsumerState<GoalPage> {
  final _weeklyCtrl = TextEditingController();
  final _monthlyCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(budgetGoalProvider);
    _weeklyCtrl.text = goal.weeklyLimit.toStringAsFixed(0);
    _monthlyCtrl.text = goal.monthlyLimit.toStringAsFixed(0);
    return Scaffold(
      appBar: AppBar(title: const Text('목표/예산')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _weeklyCtrl,
              decoration: const InputDecoration(labelText: '주간 예산'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _monthlyCtrl,
              decoration: const InputDecoration(labelText: '월간 예산'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _save,
              child: const Text('저장'),
            )
          ],
        ),
      ),
    );
  }

  void _save() {
    final weekly = double.tryParse(_weeklyCtrl.text) ?? 0;
    final monthly = double.tryParse(_monthlyCtrl.text) ?? 0;
    ref.read(budgetGoalProvider.notifier).setGoal(
          weekly: weekly,
          monthly: monthly,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('예산이 저장되었습니다.')),
    );
  }
}
