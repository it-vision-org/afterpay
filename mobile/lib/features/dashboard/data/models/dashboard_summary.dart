import '../../../../core/utils/money.dart';
import '../../../expenses/data/models/expense.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.salary,
    required this.recurringExpensesTotal,
    required this.oneTimeExpensesTotal,
    required this.totalSpent,
    required this.remaining,
    required this.percentageUsed,
    required this.overBudget,
    required this.salaryPeriodStart,
    required this.salaryPeriodEnd,
    required this.recentExpenses,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      salary: parseAmount(json['salary']),
      recurringExpensesTotal: parseAmount(json['recurringExpensesTotal']),
      oneTimeExpensesTotal: parseAmount(json['oneTimeExpensesTotal']),
      totalSpent: parseAmount(json['totalSpent']),
      remaining: parseAmount(json['remaining']),
      percentageUsed: parseAmount(json['percentageUsed']),
      overBudget: json['overBudget'] as bool,
      salaryPeriodStart: DateTime.parse(json['salaryPeriodStart'] as String),
      salaryPeriodEnd: DateTime.parse(json['salaryPeriodEnd'] as String),
      recentExpenses: (json['recentExpenses'] as List<dynamic>)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final num salary;
  final num recurringExpensesTotal;
  final num oneTimeExpensesTotal;
  final num totalSpent;
  final num remaining;
  final num percentageUsed;
  final bool overBudget;
  final DateTime salaryPeriodStart;
  final DateTime salaryPeriodEnd;
  final List<Expense> recentExpenses;
}
