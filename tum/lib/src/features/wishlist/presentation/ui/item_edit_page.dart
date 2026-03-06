import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/item.dart';
import '../providers/item_provider.dart';
import 'package:uuid/uuid.dart';

class ItemEditPage extends ConsumerStatefulWidget {
  final Item? item;
  const ItemEditPage({super.key, this.item});
  @override
  ConsumerState<ItemEditPage> createState() => _ItemEditPageState();
}

class _ItemEditPageState extends ConsumerState<ItemEditPage>{
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  int _delayDays = 7;

  @override
  void initState(){
    super.initState();
    if(widget.item!=null){
      _titleCtrl.text = widget.item!.title;
      _priceCtrl.text = widget.item!.price.toString();
      _noteCtrl.text = widget.item!.note ?? '';
      _delayDays = widget.item!.delayDays;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(widget.item==null? 'Add Item':'Edit Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: _priceCtrl, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            TextField(controller: _noteCtrl, decoration: InputDecoration(labelText: 'Note')),
            DropdownButton<int>(
              value: _delayDays,
              items: [3, 7, 14, 30]
                  .map((d) => DropdownMenuItem(value: d, child: Text('$d days')))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _delayDays = v);
                }
              },
            ),
            const SizedBox(height:16),
            ElevatedButton(onPressed: _save, child: const Text('Save'))
          ],
        ),
      ),
    );
  }

  void _save(){
    final title = _titleCtrl.text.trim();
    if(title.isEmpty) return;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final id = widget.item?.id ?? const Uuid().v4();
    final item = Item(
      id: id,
      title: title,
      note: _noteCtrl.text.trim(),
      price: price,
      delayDays: _delayDays,
      category: widget.item?.category ?? '미분류',
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      imageUrl: widget.item?.imageUrl,
      url: widget.item?.url,
    );
    final notifier = ref.read(itemListProvider.notifier);
    if(widget.item==null) {
      notifier.add(item);
    } else {
      notifier.update(item);
    }
    Navigator.pop(context);
  }
}
