import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_goal.dart';

class BudgetGoalNotifier extends Notifier<BudgetGoal> {
  static const _key = 'tum_budget_goal';
  bool _loaded = false;

  @override
  BudgetGoal build() {
    if (!_loaded) {
      _loaded = true;
      _load();
    }
    return const BudgetGoal(weeklyLimit: 0, monthlyLimit: 0);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    state = BudgetGoal.fromRaw(raw);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state.toRaw());
  }

  Future<void> setGoal({required double weekly, required double monthly}) {
    state = BudgetGoal(weeklyLimit: weekly, monthlyLimit: monthly);
    return _save();
  }
}

final budgetGoalProvider =
    NotifierProvider<BudgetGoalNotifier, BudgetGoal>(BudgetGoalNotifier.new);
