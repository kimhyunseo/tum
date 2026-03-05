abstract class StorageService {
  Future<void> init();
  Future<List<Map<String,dynamic>>> loadItems();
  Future<void> saveItems(List<Map<String,dynamic>> items);
}
