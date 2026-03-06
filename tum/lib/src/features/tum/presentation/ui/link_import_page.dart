import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:tum/src/features/wishlist/data/product_parser.dart';
import 'package:tum/src/features/wishlist/domain/entities/product_parse_result.dart';
import 'package:tum/src/features/tum/domain/entities/purchase_attempt.dart';
import 'package:tum/src/features/tum/presentation/providers/purchase_provider.dart';
import 'package:tum/src/core/services/notification_service.dart';

class LinkInputPage extends StatefulWidget {
  const LinkInputPage({super.key});

  @override
  State<LinkInputPage> createState() => _LinkInputPageState();
}

class _LinkInputPageState extends State<LinkInputPage> {
  final _urlCtrl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('링크로 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(labelText: '상품 링크 입력'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _parse,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('가져오기'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _parse() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    setState(() => _loading = true);
    final res = await ProductParser.parseFromUrl(url);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LinkImportPage(parseResult: res),
      ),
    );
  }
}

class LinkImportPage extends ConsumerStatefulWidget {
  final ProductParseResult? parseResult;
  final Map<String, dynamic>? fromShare;
  const LinkImportPage({super.key, this.parseResult, this.fromShare});

  @override
  ConsumerState<LinkImportPage> createState() => _LinkImportPageState();
}

class _LinkImportPageState extends ConsumerState<LinkImportPage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _categoryCtrl;
  int _thinkDays = 1;

  @override
  void initState() {
    super.initState();
    final title = widget.parseResult?.title ?? widget.fromShare?['title'] ?? '';
    final price = widget.parseResult?.price?.toString() ??
        widget.fromShare?['price']?.toString() ??
        '';
    final category =
        widget.parseResult?.category ?? widget.fromShare?['category'] ?? '';
    _titleCtrl = TextEditingController(text: title);
    _priceCtrl = TextEditingController(text: price);
    _categoryCtrl = TextEditingController(text: category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('빠른 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if ((widget.parseResult?.imageUrl ?? widget.fromShare?['image']) != null)
              Image.network(
                (widget.parseResult?.imageUrl ?? widget.fromShare?['image']) as String,
                height: 150,
              ),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('생각 타이머 (일) 선택'),
            ),
            const SizedBox(height: 6),
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
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('저장')),
          ],
        ),
      ),
    );
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final amount = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final record = PurchaseAttempt(
      id: const Uuid().v4(),
      title: title,
      category: _categoryCtrl.text.trim(),
      amount: amount,
      emotion: '',
      createdAt: DateTime.now(),
      thinkUntil: DateTime.now().add(Duration(days: _thinkDays)),
      status: 'thinking',
      imageUrl: widget.parseResult?.imageUrl ?? widget.fromShare?['image'],
      sourceUrl: widget.parseResult?.sourceUrl ?? widget.fromShare?['source'],
    );
    ref.read(purchaseListProvider.notifier).add(record);
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
