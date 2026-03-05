import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import 'item_edit_page.dart';
import 'item_detail_page.dart';

class ItemListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemListProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Wish list')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i){
          final it = items[i];
          return ListTile(
            title: Text(it.title),
            subtitle: Text(it.status),
            trailing: Text(it.price!=null?'${it.price}':'') ,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailPage(item: it))),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemEditPage())),
      ),
    );
  }
}
