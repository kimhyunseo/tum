import 'dart:convert';
import 'storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsStorageService implements StorageService {
  static const _key = 'tum_items';
  SharedPrefsStorageService();

  @override
  Future<void> init() async {
    // No-op for shared_preferences, but keep for interface consistency
    await SharedPreferences.getInstance();
  }

  @override
  Future<List<Map<String, dynamic>>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null || s.isEmpty) return [];
    try {
      final List<dynamic> arr = json.decode(s);
      return arr.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveItems(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final s = json.encode(items);
    await prefs.setString(_key, s);
  }
}
