import '../../../../core/utils/money.dart';
import '../../../expenses/data/models/category.dart';

class RecurringExpense {
  const RecurringExpense({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.description,
    required this.active,
    required this.icon,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecurringExpense.fromJson(Map<String, dynamic> json) {
    return RecurringExpense(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: parseAmount(json['amount']),
      category: Category.fromApiValue(json['category'] as String),
      description: json['description'] as String?,
      active: json['active'] as bool,
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
  final String? description;
  final bool active;
  final String? icon;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
}
