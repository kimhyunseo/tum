import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/purchase_record.dart';
import '../providers/purchase_record_provider.dart';
import 'package:tum/src/core/services/notification_service.dart';

class PurchaseAttemptPage extends ConsumerStatefulWidget {
  const PurchaseAttemptPage({super.key});

  @override
  ConsumerState<PurchaseAttemptPage> createState() =>
      _PurchaseAttemptPageState();
}

class _PurchaseAttemptPageState extends ConsumerState<PurchaseAttemptPage> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _emotionCtrl = TextEditingController();
  int _thinkDays = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('구매 생각 시작')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: '상품/구매 내용'),
            ),
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: '금액'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: '카테고리'),
            ),
            TextField(
              controller: _emotionCtrl,
              decoration: const InputDecoration(labelText: '감정 상태'),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('생각 타이머 (일) 선택'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [1, 5, 15]
                  .map((d) => ChoiceChip(
                        label: Text('$d일'),
                        selected: _thinkDays == d,
                        onSelected: (_) => setState(() => _thinkDays = d),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('대체 행동 제안: 산책, 기록, 미루기'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _startThinking,
              child: const Text('생각 시작'),
            )
          ],
        ),
      ),
    );
  }

  void _startThinking() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final record = PurchaseRecord(
      id: const Uuid().v4(),
      title: title,
      category: _categoryCtrl.text.trim(),
      amount: amount,
      emotion: _emotionCtrl.text.trim(),
      createdAt: DateTime.now(),
      thinkUntil: DateTime.now().add(Duration(days: _thinkDays)),
      status: 'thinking',
    );
    ref.read(purchaseRecordProvider.notifier).add(record);
    NotificationService.scheduleReminder(
      id: record.id.hashCode,
      title: '생각 타이머 종료',
      body: '"${record.title}" 구매 여부를 결정해 주세요.',
      scheduledAt: record.thinkUntil!,
      payload: record.id,
    );
    Navigator.pop(context);
  }
}
