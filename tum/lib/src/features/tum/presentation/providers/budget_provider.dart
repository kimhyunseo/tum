import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/budget_goal.dart';

part 'budget_provider.g.dart';

@riverpod
class Budget extends _$Budget {
  static const _key = 'budget_goal';

  @override
  BudgetGoal build() {
    _load();
    return const BudgetGoal(weeklyLimit: 0, monthlyLimit: 0);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      state = BudgetGoal.fromRaw(json.decode(raw));
    }
  }

  Future<void> update(BudgetGoal goal) async {
    state = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(goal.toRaw()));
  }
}
