import 'dart:io';
import 'package:flutter/material.dart';
import '../models/wardrobe_item.dart';
import '../services/storage_service.dart';
import 'add_item_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final StorageService storage = StorageService();
  List<WardrobeItem> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final l = await storage.loadItems();
    setState(() {
      items = l;
      loading = false;
    });
  }

  Future<void> _delete(String id) async {
    setState(() => items.removeWhere((e) => e.id == id));
    await storage.saveItems(items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('옷장')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('아직 아이템이 없어요. + 버튼을 눌러 추가하세요.'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, idx) {
                    final it = items[idx];
                    return ListTile(
                      onTap: () async {
                        // Pass an onAdd callback so AddItemScreen can save directly, and also handle returned item
                        final updated = await Navigator.of(context).push<WardrobeItem?>(
                            MaterialPageRoute(builder: (_) => AddItemScreen(onAdd: (added) async {
                                  final idx = items.indexWhere((e) => e.id == added.id);
                                  if (idx == -1) {
                                    setState(() => items.add(added));
                                  } else {
                                    setState(() => items[idx] = added);
                                  }
                                  await storage.saveItems(items);
                                }, existing: it)));
                        if (updated != null) {
                          final idx = items.indexWhere((e) => e.id == updated.id);
                          if (idx != -1) {
                            setState(() => items[idx] = updated);
                            await storage.saveItems(items);
                          }
                        }
                      },
                      leading: it.imagePath != null
                          ? Image.file(
                              File(it.imagePath!),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : const CircleAvatar(child: Icon(Icons.checkroom)),
                      title: Text(it.name),
                      subtitle: Text('${it.category} · ${it.minTemp}°C–${it.maxTemp}°C ${it.waterproof ? '· 방수' : ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  title: const Text('Delete?'),
                                  content: Text('Delete ${it.name}?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                                    TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _delete(it.id);
                                        },
                                        child: const Text('삭제'))
                                  ],
                                )),
                      ),
                    );
                  },
                ),
    );
  }
}
