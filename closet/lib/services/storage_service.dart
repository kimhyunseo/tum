import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/wardrobe_item.dart';

class StorageService {
  Future<Directory> _appDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir;
  }

  Future<File> _dataFile() async {
    final dir = await _appDir();
    final file = File('${dir.path}/wardrobe.json');
    return file;
  }

  Future<List<WardrobeItem>> loadItems() async {
    try {
      final f = await _dataFile();
      if (!await f.exists()) return [];
      final s = await f.readAsString();
      final List<dynamic> j = json.decode(s);
      return j.map((e) => WardrobeItem.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveItems(List<WardrobeItem> items) async {
    final f = await _dataFile();
    final j = items.map((e) => e.toJson()).toList();
    await f.writeAsString(json.encode(j));
  }
}
