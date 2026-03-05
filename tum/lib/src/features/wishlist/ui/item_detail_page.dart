import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;
  ItemDetailPage({required this.item});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: \\$${item.price ?? '-'}'),
            SizedBox(height:8),
            Text('Note: ${item.note ?? ''}'),
            SizedBox(height:8),
            Text('Status: ${item.status}'),
            SizedBox(height:16),
            ElevatedButton(onPressed: ()=>Navigator.pop(context), child: Text('Back'))
          ],
        ),
      ),
    );
  }
}
