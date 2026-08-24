import '../../../../core/utils/money.dart';

class SalarySource {
  const SalarySource({
    required this.id,
    required this.name,
    required this.amount,
    required this.payDay,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalarySource.fromJson(Map<String, dynamic> json) {
    return SalarySource(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: parseAmount(json['amount']),
      payDay: json['payDay'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String name;
  final num amount;
  final int? payDay;
  final DateTime createdAt;
  final DateTime updatedAt;
}
