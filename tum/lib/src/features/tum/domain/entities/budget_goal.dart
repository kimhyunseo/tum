import 'package:equatable/equatable.dart';

class BudgetGoal extends Equatable {
  final double weeklyLimit;
  final double monthlyLimit;

  const BudgetGoal({
    required this.weeklyLimit,
    required this.monthlyLimit,
  });

  factory BudgetGoal.fromRaw(Map<String, dynamic> m) => BudgetGoal(
    weeklyLimit: m['weeklyLimit'] ?? 0.0,
    monthlyLimit: m['monthlyLimit'] ?? 0.0,
  );

  Map<String, dynamic> toRaw() => {
    'weeklyLimit': weeklyLimit,
    'monthlyLimit': monthlyLimit,
  };

  @override
  List<Object?> get props => [weeklyLimit, monthlyLimit];

  BudgetGoal copyWith({
    double? weeklyLimit,
    double? monthlyLimit,
  }) {
    return BudgetGoal(
      weeklyLimit: weeklyLimit ?? this.weeklyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }
}
