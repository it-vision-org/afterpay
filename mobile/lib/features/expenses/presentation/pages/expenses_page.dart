import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/models/expense_period.dart';
import '../controllers/expenses_controller.dart';
import '../widgets/expense_tile.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  static const _tabs = [
    (ExpensePeriod.current, 'Current period'),
    (ExpensePeriod.previous, 'Previous period'),
    (ExpensePeriod.all, 'All'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(expensesPeriodFilterProvider);
    final expensesAsync = ref.watch(expensesControllerProvider);
    final currency = ref.watch(authControllerProvider).value?.currency ?? 'TND';

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs
                    .map(
                      (tab) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tab.$2),
                          selected: selectedFilter == tab.$1,
                          onSelected: (_) =>
                              ref
                                      .read(expensesPeriodFilterProvider.notifier)
                                      .state =
                                  tab.$1,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(expensesControllerProvider.notifier).refresh(),
              child: expensesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ErrorView(
                  error: error,
                  onRetry: () =>
                      ref.read(expensesControllerProvider.notifier).refresh(),
                ),
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 64),
                          child: EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: "You're all clear",
                            message:
                                'No expenses recorded for this salary period.',
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: expenses.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return ExpenseTile(
                        expense: expense,
                        currency: currency,
                        onTap: () => context.push('/expenses/${expense.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
