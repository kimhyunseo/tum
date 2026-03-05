import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item.dart';
import 'package:tum/src/core/storage/storage_service.dart';
import 'package:tum/src/core/storage/shared_prefs_storage_service.dart';

class ItemListNotifier extends Notifier<List<Item>> {
  late final StorageService _storage;
  bool _loaded = false;

  @override
  List<Item> build() {
    _storage = ref.watch(storageProvider);
    if (!_loaded) {
      _loaded = true;
      _load();
    }
    return [];
  }

  Future<void> _load() async {
    final raw = await _storage.loadItems();
    state = raw.map((m)=> Item.fromJson(m)).toList();
  }

  Future<void> add(Item item){
    state = [...state, item];
    return _storage.saveItems(state.map((e)=>e.toJson()).toList());
  }
  Future<void> remove(String id){
    state = state.where((i)=>i.id!=id).toList();
    return _storage.saveItems(state.map((e)=>e.toJson()).toList());
  }
  Future<void> update(Item item){
    state = state.map((i)=> i.id==item.id ? item : i).toList();
    return _storage.saveItems(state.map((e)=>e.toJson()).toList());
  }
}

final storageProvider = Provider<StorageService>((ref){
  // Default implementation: use SharedPrefs for local testing.
  return SharedPrefsStorageService();
});

final itemListProvider = NotifierProvider<ItemListNotifier, List<Item>>(ItemListNotifier.new);
