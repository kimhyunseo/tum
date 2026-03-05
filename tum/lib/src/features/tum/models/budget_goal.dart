import 'dart:convert';

class BudgetGoal {
  final double weeklyLimit;
  final double monthlyLimit;

  const BudgetGoal({
    required this.weeklyLimit,
    required this.monthlyLimit,
  });

  BudgetGoal copyWith({
    double? weeklyLimit,
    double? monthlyLimit,
  }) {
    return BudgetGoal(
      weeklyLimit: weeklyLimit ?? this.weeklyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }

  Map<String, dynamic> toJson() => {
        'weeklyLimit': weeklyLimit,
        'monthlyLimit': monthlyLimit,
      };

  static BudgetGoal fromJson(Map<String, dynamic> json) {
    return BudgetGoal(
      weeklyLimit: (json['weeklyLimit'] as num).toDouble(),
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    );
  }

  String toRaw() => jsonEncode(toJson());
  static BudgetGoal fromRaw(String raw) =>
      BudgetGoal.fromJson(jsonDecode(raw));
}
