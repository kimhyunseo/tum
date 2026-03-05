import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import 'package:collection/collection.dart';

class ItemListNotifier extends StateNotifier<List<Item>> {
  ItemListNotifier(): super([]);

  void add(Item item){
    state = [...state, item];
  }
  void remove(String id){
    state = state.where((i)=>i.id!=id).toList();
  }
  void update(Item item){
    state = state.map((i)=> i.id==item.id ? item : i).toList();
  }
}

final itemListProvider = StateNotifierProvider<ItemListNotifier, List<Item>>((ref)=>ItemListNotifier());
