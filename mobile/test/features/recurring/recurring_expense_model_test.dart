import 'package:afterpay/features/expenses/data/models/category.dart';
import 'package:afterpay/features/recurring/data/models/recurring_expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecurringExpense.fromJson', () {
    test('parses an active recurring expense', () {
      final recurring = RecurringExpense.fromJson({
        'id': 'rec-1',
        'name': 'Rent',
        'amount': 700,
        'category': 'HOUSING',
        'description': null,
        'active': true,
        'icon': null,
        'color': null,
        'createdAt': '2026-08-01T10:00:00Z',
        'updatedAt': '2026-08-01T10:00:00Z',
      });

      expect(recurring.name, 'Rent');
      expect(recurring.amount, 700);
      expect(recurring.category, Category.housing);
      expect(recurring.active, isTrue);
    });

    test('parses an inactive recurring expense', () {
      final recurring = RecurringExpense.fromJson({
        'id': 'rec-2',
        'name': 'Gym',
        'amount': '40.00',
        'category': 'HEALTH',
        'description': 'Paused membership',
        'active': false,
        'icon': null,
        'color': null,
        'createdAt': '2026-08-01T10:00:00Z',
        'updatedAt': '2026-08-01T10:00:00Z',
      });

      expect(recurring.active, isFalse);
      expect(recurring.description, 'Paused membership');
    });
  });
}
