// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Budget)
final budgetProvider = BudgetProvider._();

final class BudgetProvider extends $NotifierProvider<Budget, BudgetGoal> {
  BudgetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetHash();

  @$internal
  @override
  Budget create() => Budget();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetGoal value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetGoal>(value),
    );
  }
}

String _$budgetHash() => r'1e998231fa00912cf352adb486de5fdaff4f1e42';

abstract class _$Budget extends $Notifier<BudgetGoal> {
  BudgetGoal build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BudgetGoal, BudgetGoal>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BudgetGoal, BudgetGoal>,
              BudgetGoal,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
