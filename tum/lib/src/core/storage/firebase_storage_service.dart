import 'storage_service.dart';

// Placeholder Firebase storage service. This file provides a concrete
// implementation surface for when Firebase is connected. For now methods
// throw unimplemented errors or act as no-ops to keep the app compilable.

class FirebaseStorageService implements StorageService {
  @override
  Future<void> init() async {
    // TODO: Initialize Firebase and Firestore clients here when integrating.
    // e.g., await Firebase.initializeApp();
    return;
  }

  @override
  Future<List<Map<String, dynamic>>> loadItems() async {
    // TODO: Query Firestore collection and return list of item maps.
    return [];
  }

  @override
  Future<void> saveItems(List<Map<String, dynamic>> items) async {
    // TODO: Write items to Firestore (batch write / upsert by id).
    return;
  }
}
