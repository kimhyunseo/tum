import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/purchase_attempt.dart';
import '../../domain/repositories/purchase_repository.dart';

class LocalPurchaseRepository implements PurchaseRepository {
  static const _key = 'purchase_records';

  @override
  Future<List<PurchaseAttempt>> getPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((j) => _fromMap(json.decode(j))).toList();
  }

  @override
  Future<void> addPurchase(PurchaseAttempt p) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getPurchases();
    list.add(p);
    await prefs.setStringList(_key, list.map((item) => json.encode(_toMap(item))).toList());
  }

  @override
  Future<void> updatePurchaseStatus(String id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getPurchases();
    final index = list.indexWhere((p) => p.id == id);
    if (index != -1) {
      list[index] = list[index].copyWith(status: status);
      await prefs.setStringList(_key, list.map((item) => json.encode(_toMap(item))).toList());
    }
  }

  Map<String, dynamic> _toMap(PurchaseAttempt p) => {
    'id': p.id,
    'title': p.title,
    'category': p.category,
    'amount': p.amount,
    'emotion': p.emotion,
    'createdAt': p.createdAt.toIso8601String(),
    'thinkUntil': p.thinkUntil?.toIso8601String(),
    'status': p.status,
    'imageUrl': p.imageUrl,
    'sourceUrl': p.sourceUrl,
  };

  PurchaseAttempt _fromMap(Map<String, dynamic> m) => PurchaseAttempt(
    id: m['id'],
    title: m['title'],
    category: m['category'],
    amount: m['amount'],
    emotion: m['emotion'],
    createdAt: DateTime.parse(m['createdAt']),
    thinkUntil: m['thinkUntil'] != null ? DateTime.parse(m['thinkUntil']) : null,
    status: m['status'],
    imageUrl: m['imageUrl'],
    sourceUrl: m['sourceUrl'],
  );
}
