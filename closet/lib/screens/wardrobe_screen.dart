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
    // find item to delete (to remove image file too)
    final idx = items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final toRemove = items[idx];
      if (toRemove.imagePath != null) {
        try {
          final f = File(toRemove.imagePath!);
          if (await f.exists()) {
            await f.delete();
          }
        } catch (e) {
          // ignore deletion errors but log optionally
          // print('Failed to delete image file: $e');
        }
      }
    }
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
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.checkroom, size: 56, color: Colors.teal),
                            const SizedBox(height: 12),
                            const Text('옷장이 비어있어요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            const Text('하단의 + 버튼을 눌러 옷을 추가해보세요. 사진으로 빠르게 추가할 수 있어요.', textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                // open AddItemScreen directly for quick add
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddItemScreen(onAdd: (added) async {
                                  final idx = items.indexWhere((e) => e.id == added.id);
                                  if (idx == -1) {
                                    setState(() => items.add(added));
                                  } else {
                                    setState(() => items[idx] = added);
                                  }
                                  await storage.saveItems(items);
                                })));
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('아이템 추가하기'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                                onPressed: () async {
                                  // add sample data for quick start
                                  final samples = [
                                    WardrobeItem(id: 'sample1', name: '흰 티셔츠', category: 'top', minTemp: 15, maxTemp: 30, waterproof: false, imagePath: null),
                                    WardrobeItem(id: 'sample2', name: '청바지', category: 'bottom', minTemp: 5, maxTemp: 30, waterproof: false, imagePath: null),
                                    WardrobeItem(id: 'sample3', name: '경량 패딩', category: 'outer', minTemp: -5, maxTemp: 10, waterproof: false, imagePath: null),
                                    WardrobeItem(id: 'sample4', name: '스니커즈', category: 'shoes', minTemp: 0, maxTemp: 30, waterproof: false, imagePath: null),
                                  ];
                                  for (final s in samples) {
                                    await storage.saveItems([...items, s]);
                                    items.add(s);
                                  }
                                  setState(() {});
                                },
                                child: const Text('샘플 데이터 추가'))
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, idx) {
                    final it = items[idx];
                    return Card(
                      child: InkWell(
                        onTap: () async {
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[100]),
                                child: it.imagePath != null
                                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(it.imagePath!), width: 64, height: 64, fit: BoxFit.cover))
                                    : const Icon(Icons.checkroom, size: 36, color: Colors.black54),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(it.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('${it.category} · ${it.minTemp}°C–${it.maxTemp}°C', style: TextStyle(color: Colors.grey[600])),
                                    if (it.waterproof) Text('방수', style: TextStyle(color: Colors.teal[700], fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final updated = await Navigator.of(context).push<WardrobeItem?>(
                                      MaterialPageRoute(builder: (_) => AddItemScreen(onAdd: (added) async {}, existing: it)));
                                  if (updated != null) {
                                    final idx = items.indexWhere((e) => e.id == updated.id);
                                    if (idx != -1) {
                                      setState(() => items[idx] = updated);
                                      await storage.saveItems(items);
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          title: const Text('삭제'),
                                          content: Text('${it.name} 을(를) 삭제할까요?'),
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
