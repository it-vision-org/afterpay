import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../data/models/recurring_expense.dart';
import '../controllers/recurring_expenses_controller.dart';

class RecurringExpensesPage extends ConsumerWidget {
  const RecurringExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(recurringExpensesControllerProvider);
    final currency = ref.watch(authControllerProvider).value?.currency ?? 'TND';

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring expenses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recurring/new'),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(recurringExpensesControllerProvider.notifier).refresh(),
        child: recurringAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () => ref
                .read(recurringExpensesControllerProvider.notifier)
                .refresh(),
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: EmptyState(
                      icon: Icons.autorenew,
                      title: 'No monthly commitments yet',
                      message:
                          'Add your recurring expenses to see what remains '
                          'after your fixed costs.',
                    ),
                  ),
                ],
              );
            }

            final activeTotal = items
                .where((item) => item.active)
                .fold<num>(0, (sum, item) => sum + item.amount);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total recurring',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          formatMoney(activeTotal, currency),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final item in items) ...[
                        _RecurringExpenseRow(item: item, currency: currency),
                        if (item != items.last)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecurringExpenseRow extends ConsumerWidget {
  const _RecurringExpenseRow({required this.item, required this.currency});

  final RecurringExpense item;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.12),
        child: Icon(
          item.category.icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        item.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: item.active
              ? null
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(item.category.label),
      onTap: () => context.push('/recurring/${item.id}/edit', extra: item),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatMoney(item.amount, currency),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: item.active
                  ? null
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Switch(
            value: item.active,
            onChanged: (value) async {
              await ref
                  .read(recurringExpensesControllerProvider.notifier)
                  .toggleActive(item.id, value);
              ref.invalidate(dashboardControllerProvider);
            },
          ),
        ],
      ),
    );
  }
}
