import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/purchase_record_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(purchaseRecordProvider);
    final bought = records.where((r) => r.status == 'bought').toList();
    final total = bought.fold<double>(0, (sum, r) => sum + r.amount);
    final count = bought.length;

    final categoryMap = <String, double>{};
    for (final r in bought) {
      final key = r.category.isEmpty ? '미분류' : r.category;
      categoryMap[key] = (categoryMap[key] ?? 0) + r.amount;
    }
    final categoryEntries = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < categoryEntries.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: categoryEntries[i].value,
              width: 18,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
      );
    }

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
            const Text('카테고리별 지출'),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: categoryEntries.isEmpty
                  ? const Center(child: Text('데이터가 없습니다.'))
                  : BarChart(
                      BarChartData(
                        barGroups: barGroups,
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= categoryEntries.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    categoryEntries[idx].key,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            const Text('간단 분석: 감정 상태별 소비 패턴을 기록해봐요'),
          ],
        ),
      ),
    );
  }
}
