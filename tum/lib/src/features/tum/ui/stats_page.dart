import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/purchase_record_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(purchaseRecordProvider);
    final bought = records.where((r) => r.status == 'bought').toList();
    final total = bought.fold<double>(0, (sum, r) => sum + r.amount);
    final count = bought.length;
    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('구매 완료: $count건'),
            const SizedBox(height: 8),
            Text('총 지출: ${total.toStringAsFixed(0)}원'),
            const SizedBox(height: 16),
            const Text('간단 분석: 감정 상태별 소비 패턴을 기록해봐요'),
          ],
        ),
      ),
    );
  }
}
