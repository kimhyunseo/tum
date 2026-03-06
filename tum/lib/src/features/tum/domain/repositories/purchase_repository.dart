import '../../domain/entities/purchase_attempt.dart';

abstract class PurchaseRepository {
  Future<List<PurchaseAttempt>> getPurchases();
  Future<void> addPurchase(PurchaseAttempt purchase);
  Future<void> updatePurchaseStatus(String id, String status);
}
