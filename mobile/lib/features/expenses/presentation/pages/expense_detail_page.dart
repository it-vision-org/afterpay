import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../data/repositories/expense_repository.dart';
import '../controllers/expenses_controller.dart';

class ExpenseDetailPage extends ConsumerWidget {
  const ExpenseDetailPage({required this.expenseId, super.key});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(expenseDetailProvider(expenseId));
    final currency = ref.watch(authControllerProvider).value?.currency ?? 'TND';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense'),
        actions: [
          expenseAsync.maybeWhen(
            data: (expense) => IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push('/expenses/$expenseId/edit', extra: expense),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          expenseAsync.maybeWhen(
            data: (expense) => IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: expenseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(expenseDetailProvider(expenseId)),
        ),
        data: (expense) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        expense.category.icon,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      formatMoney(expense.amount, currency),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expense.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: const Text('Category'),
                      trailing: Text(expense.category.label),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Date'),
                      trailing: Text(
                        DateFormat('d MMM yyyy').format(expense.expenseDate),
                      ),
                    ),
                    if (expense.note?.isNotEmpty == true) ...[
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.notes_outlined),
                        title: const Text('Note'),
                        subtitle: Text(expense.note!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(expenseRepositoryProvider).delete(expenseId);
    ref.invalidate(expensesControllerProvider);
    ref.invalidate(dashboardControllerProvider);
    if (context.mounted) context.pop();
  }
}
