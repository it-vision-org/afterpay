import 'package:afterpay/features/dashboard/data/models/dashboard_summary.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _baseJson({
  required num salary,
  required num totalSpent,
  required num remaining,
  required num percentageUsed,
  required bool overBudget,
}) {
  return {
    'salary': salary,
    'recurringExpensesTotal': 0,
    'oneTimeExpensesTotal': totalSpent,
    'totalSpent': totalSpent,
    'remaining': remaining,
    'percentageUsed': percentageUsed,
    'overBudget': overBudget,
    'salaryPeriodStart': '2026-07-25',
    'salaryPeriodEnd': '2026-08-24',
    'recentExpenses': <dynamic>[],
  };
}

void main() {
  group('DashboardSummary.fromJson', () {
    test('parses a normal within-budget summary', () {
      final summary = DashboardSummary.fromJson(
        _baseJson(
          salary: 2000,
          totalSpent: 1010,
          remaining: 990,
          percentageUsed: 50.5,
          overBudget: false,
        ),
      );

      expect(summary.salary, 2000);
      expect(summary.remaining, 990);
      expect(summary.overBudget, isFalse);
      expect(summary.salaryPeriodStart, DateTime.parse('2026-07-25'));
      expect(summary.salaryPeriodEnd, DateTime.parse('2026-08-24'));
      expect(summary.recentExpenses, isEmpty);
    });

    test('parses an over-budget summary with negative remaining', () {
      final summary = DashboardSummary.fromJson(
        _baseJson(
          salary: 2000,
          totalSpent: 2300,
          remaining: -300,
          percentageUsed: 115,
          overBudget: true,
        ),
      );

      expect(summary.remaining, -300);
      expect(summary.overBudget, isTrue);
      expect(summary.percentageUsed, 115);
    });

    test('handles a zero salary without dividing by zero upstream', () {
      final summary = DashboardSummary.fromJson(
        _baseJson(
          salary: 0,
          totalSpent: 0,
          remaining: 0,
          percentageUsed: 0,
          overBudget: false,
        ),
      );

      expect(summary.salary, 0);
      expect(summary.percentageUsed, 0);
      expect(summary.overBudget, isFalse);
    });
  });
}
