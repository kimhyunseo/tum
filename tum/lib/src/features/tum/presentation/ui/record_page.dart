import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/purchase_provider.dart';

class RecordPage extends ConsumerWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(purchaseListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('기록')),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (records) => ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, i) {
            final r = records[i];
            return ListTile(
              leading: r.imageUrl != null
                  ? Image.network(r.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)
                  : null,
              title: Text(r.title),
              subtitle: Text('${r.category} • ${r.emotion}'),
              trailing: Text(r.status),
              onTap: () => _showActions(context, ref, r.id),
            );
          },
        ),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, String id) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('구매함'),
              onTap: () {
                ref.read(purchaseListProvider.notifier).updateStatus(id, 'bought');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('구매 안함'),
              onTap: () {
                ref.read(purchaseListProvider.notifier).updateStatus(id, 'skipped');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
