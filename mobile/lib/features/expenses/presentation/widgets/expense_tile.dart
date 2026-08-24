import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/money.dart';
import '../../data/models/expense.dart';

final _dateFormat = DateFormat('d MMM yyyy');

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    required this.expense,
    required this.currency,
    this.onTap,
    super.key,
  });

  final Expense expense;
  final String currency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
        child: Icon(expense.category.icon, color: colorScheme.primary),
      ),
      title: Text(
        expense.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        expense.note?.isNotEmpty == true
            ? expense.note!
            : '${expense.category.label} · ${_dateFormat.format(expense.expenseDate)}',
      ),
      trailing: Text(
        formatMoney(expense.amount, currency),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
