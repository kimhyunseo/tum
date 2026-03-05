import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/purchase_record_provider.dart';
import '../providers/budget_goal_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(purchaseRecordProvider);
    final goal = ref.watch(budgetGoalProvider);
    final bought = records.where((r) => r.status == 'bought').toList();
    final total = bought.fold<double>(0, (sum, r) => sum + r.amount);
    final count = bought.length;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final weekTotal = bought
        .where((r) => r.createdAt.isAfter(weekStart))
        .fold<double>(0, (sum, r) => sum + r.amount);
    final monthTotal = bought
        .where((r) => r.createdAt.isAfter(monthStart))
        .fold<double>(0, (sum, r) => sum + r.amount);

    final categoryMap = <String, double>{};
    final emotionMap = <String, double>{};
    for (final r in bought) {
      final cat = r.category.isEmpty ? '미분류' : r.category;
      final emo = r.emotion.isEmpty ? '중립' : r.emotion;
      categoryMap[cat] = (categoryMap[cat] ?? 0) + r.amount;
      emotionMap[emo] = (emotionMap[emo] ?? 0) + r.amount;
    }

    final categoryEntries = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final emotionEntries = emotionMap.entries.toList()
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

    final emotionSections = <PieChartSectionData>[];
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    for (var i = 0; i < emotionEntries.length; i++) {
      emotionSections.add(
        PieChartSectionData(
          value: emotionEntries[i].value,
          title: emotionEntries[i].key,
          color: colors[i % colors.length],
          radius: 50,
          titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    }

    final monthlyProgress =
        goal.monthlyLimit == 0 ? 0.0 : monthTotal / goal.monthlyLimit;
    final weeklyProgress =
        goal.weeklyLimit == 0 ? 0.0 : weekTotal / goal.weeklyLimit;

    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('구매 완료: $count건'),
          const SizedBox(height: 8),
          Text('총 지출: ${total.toStringAsFixed(0)}원'),
          const SizedBox(height: 16),
          const Text('주/월 지출 요약'),
          const SizedBox(height: 8),
          Text('이번 주: ${weekTotal.toStringAsFixed(0)}원'),
          LinearProgressIndicator(value: weeklyProgress.clamp(0, 1)),
          const SizedBox(height: 8),
          Text('이번 달: ${monthTotal.toStringAsFixed(0)}원'),
          LinearProgressIndicator(value: monthlyProgress.clamp(0, 1)),
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
          const Text('감정별 지출 분포'),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: emotionEntries.isEmpty
                ? const Center(child: Text('데이터가 없습니다.'))
                : PieChart(PieChartData(sections: emotionSections)),
          ),
          const SizedBox(height: 16),
          const Text('간단 분석: 감정 상태별 소비 패턴을 기록해봐요'),
        ],
      ),
    );
  }
}
