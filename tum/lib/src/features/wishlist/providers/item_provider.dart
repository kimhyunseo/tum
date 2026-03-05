import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import 'package:collection/collection.dart';
import '../../core/storage/storage_service.dart';

class ItemListNotifier extends StateNotifier<List<Item>> {
  final StorageService storage;
  ItemListNotifier(this.storage): super([]);

  Future<void> load() async {
    final raw = await storage.loadItems();
    state = raw.map((m)=> Item.fromJson(m)).toList();
  }

  Future<void> add(Item item){
    state = [...state, item];
    return storage.saveItems(state.map((e)=>e.toJson()).toList());
  }
  Future<void> remove(String id){
    state = state.where((i)=>i.id!=id).toList();
    return storage.saveItems(state.map((e)=>e.toJson()).toList());
  }
  Future<void> update(Item item){
    state = state.map((i)=> i.id==item.id ? item : i).toList();
    return storage.saveItems(state.map((e)=>e.toJson()).toList());
  }
}

final storageProvider = Provider<StorageService>((ref){
  // Default to FirebaseStorageService; replace with local implementation if needed.
  throw UnimplementedError('Provide a StorageService implementation in main');
});

final itemListProvider = StateNotifierProvider<ItemListNotifier, List<Item>>((ref){
  final storage = ref.watch(storageProvider);
  final notifier = ItemListNotifier(storage);
  notifier.load();
  return notifier;
});
