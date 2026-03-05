import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/purchase_record.dart';

class PurchaseRecordNotifier extends Notifier<List<PurchaseRecord>> {
  static const _key = 'tum_records';
  bool _loaded = false;

  @override
  List<PurchaseRecord> build() {
    if (!_loaded) {
      _loaded = true;
      _load();
    }
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    state = rawList.map(PurchaseRecord.fromRaw).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      state.map((e) => e.toRaw()).toList(),
    );
  }

  Future<void> add(PurchaseRecord record) {
    state = [...state, record];
    return _save();
  }

  Future<void> updateStatus(String id, String status) {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(status: status) else r
    ];
    return _save();
  }

  Future<void> remove(String id) {
    state = state.where((r) => r.id != id).toList();
    return _save();
  }
}

final purchaseRecordProvider =
    NotifierProvider<PurchaseRecordNotifier, List<PurchaseRecord>>(
        PurchaseRecordNotifier.new);
