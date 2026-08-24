import 'package:afterpay/features/expenses/data/models/category.dart';
import 'package:afterpay/features/expenses/data/models/expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Expense.fromJson', () {
    test('parses a full expense', () {
      final expense = Expense.fromJson({
        'id': 'exp-1',
        'name': 'Groceries',
        'amount': 83.5,
        'category': 'FOOD',
        'expenseDate': '2026-08-18',
        'note': 'Weekly shop',
        'icon': null,
        'color': null,
        'createdAt': '2026-08-18T10:00:00Z',
        'updatedAt': '2026-08-18T10:00:00Z',
      });

      expect(expense.id, 'exp-1');
      expect(expense.name, 'Groceries');
      expect(expense.amount, 83.5);
      expect(expense.category, Category.food);
      expect(expense.expenseDate, DateTime.parse('2026-08-18'));
      expect(expense.note, 'Weekly shop');
    });

    test('parses a string amount', () {
      final expense = Expense.fromJson({
        'id': 'exp-2',
        'name': 'Taxi',
        'amount': '12.50',
        'category': 'TRANSPORTATION',
        'expenseDate': '2026-08-20',
        'note': null,
        'icon': null,
        'color': null,
        'createdAt': '2026-08-20T10:00:00Z',
        'updatedAt': '2026-08-20T10:00:00Z',
      });

      expect(expense.amount, 12.5);
      expect(expense.category, Category.transportation);
    });
  });

  group('Category', () {
    test('round-trips every value through the API value', () {
      for (final category in Category.values) {
        expect(Category.fromApiValue(category.apiValue), category);
      }
    });
  });
}
