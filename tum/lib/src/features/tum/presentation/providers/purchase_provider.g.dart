// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(purchaseRepository)
final purchaseRepositoryProvider = PurchaseRepositoryProvider._();

final class PurchaseRepositoryProvider
    extends
        $FunctionalProvider<
          PurchaseRepository,
          PurchaseRepository,
          PurchaseRepository
        >
    with $Provider<PurchaseRepository> {
  PurchaseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseRepositoryHash();

  @$internal
  @override
  $ProviderElement<PurchaseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchaseRepository create(Ref ref) {
    return purchaseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseRepository>(value),
    );
  }
}

String _$purchaseRepositoryHash() =>
    r'da3c5501bba99c15fd806be93f8481f53742959c';

@ProviderFor(PurchaseList)
final purchaseListProvider = PurchaseListProvider._();

final class PurchaseListProvider
    extends $AsyncNotifierProvider<PurchaseList, List<PurchaseAttempt>> {
  PurchaseListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseListHash();

  @$internal
  @override
  PurchaseList create() => PurchaseList();
}

String _$purchaseListHash() => r'f995e00ca65677ec9927f2a936791250ac86e73a';

abstract class _$PurchaseList extends $AsyncNotifier<List<PurchaseAttempt>> {
  FutureOr<List<PurchaseAttempt>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<PurchaseAttempt>>, List<PurchaseAttempt>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PurchaseAttempt>>,
                List<PurchaseAttempt>
              >,
              AsyncValue<List<PurchaseAttempt>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
