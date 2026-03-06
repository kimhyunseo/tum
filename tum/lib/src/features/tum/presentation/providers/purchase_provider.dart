import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/purchase_attempt.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../data/repositories/local_purchase_repository.dart';

part 'purchase_provider.g.dart';

@riverpod
PurchaseRepository purchaseRepository(ref) {
  return LocalPurchaseRepository();
}

@riverpod
class PurchaseList extends _$PurchaseList {
  @override
  Future<List<PurchaseAttempt>> build() async {
    return ref.watch(purchaseRepositoryProvider).getPurchases();
  }

  Future<void> add(PurchaseAttempt p) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(purchaseRepositoryProvider).addPurchase(p);
      return ref.read(purchaseRepositoryProvider).getPurchases();
    });
  }

  Future<void> updateStatus(String id, String status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(purchaseRepositoryProvider).updatePurchaseStatus(id, status);
      return ref.read(purchaseRepositoryProvider).getPurchases();
    });
  }
}
