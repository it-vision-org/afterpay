import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/models/expenses_filter.dart';
import '../../data/models/month_selection.dart';
import '../controllers/expenses_controller.dart';
import '../widgets/expense_tile.dart';
import '../widgets/month_year_picker_sheet.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(expensesFilterProvider);
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
                children: [
                  ChoiceChip(
                    label: const Text('Current period'),
                    selected: selectedFilter is CurrentPeriodFilter,
                    onSelected: (_) =>
                        ref.read(expensesFilterProvider.notifier).state =
                            const CurrentPeriodFilter(),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('All'),
                    selected: selectedFilter is AllExpensesFilter,
                    onSelected: (_) =>
                        ref.read(expensesFilterProvider.notifier).state =
                            const AllExpensesFilter(),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(_specificChipLabel(selectedFilter)),
                    selected: selectedFilter is SpecificPeriodsFilter,
                    onSelected: (_) => _openPeriodPicker(context, ref),
                  ),
                ],
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

  String _specificChipLabel(ExpensesFilter filter) {
    if (filter is! SpecificPeriodsFilter) {
      return 'Specific period';
    }
    final months = filter.months;
    if (months.length == 1) {
      return months.first.label;
    }
    final years = months.map((m) => m.year).toSet();
    if (years.length == 1 && months.length == 12) {
      return '${years.first}';
    }
    return '${months.length} months';
  }

  Future<void> _openPeriodPicker(BuildContext context, WidgetRef ref) async {
    final currentFilter = ref.read(expensesFilterProvider);
    final preselected = currentFilter is SpecificPeriodsFilter
        ? currentFilter.months
        : const <MonthSelection>[];

    final selected = await showModalBottomSheet<List<MonthSelection>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => MonthYearPickerSheet(preselected: preselected),
    );

    if (selected != null && selected.isNotEmpty) {
      ref.read(expensesFilterProvider.notifier).state =
          SpecificPeriodsFilter(selected);
    }
  }
}
