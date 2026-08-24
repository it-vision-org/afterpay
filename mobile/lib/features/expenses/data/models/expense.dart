import '../../../../core/utils/money.dart';
import 'category.dart';

class Expense {
  const Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.expenseDate,
    required this.note,
    required this.icon,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: parseAmount(json['amount']),
      category: Category.fromApiValue(json['category'] as String),
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      note: json['note'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String name;
  final num amount;
  final Category category;
  final DateTime expenseDate;
  final String? note;
  final String? icon;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
}
