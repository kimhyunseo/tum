import 'package:flutter/material.dart';
import '../../domain/entities/item.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;
  const ItemDetailPage({super.key, required this.item});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ${item.price ?? '-'}'),
            const SizedBox(height:8),
            Text('Note: ${item.note ?? ''}'),
            const SizedBox(height:8),
            Text('Status: ${item.status}'),
            const SizedBox(height:16),
            ElevatedButton(onPressed: ()=>Navigator.pop(context), child: const Text('Back'))
          ],
        ),
      ),
    );
  }
}
