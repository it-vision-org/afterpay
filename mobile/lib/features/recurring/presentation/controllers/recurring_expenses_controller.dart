import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/recurring_expense.dart';
import '../../data/repositories/recurring_expense_repository.dart';

final recurringExpensesControllerProvider =
    AsyncNotifierProvider.autoDispose<
      RecurringExpensesController,
      List<RecurringExpense>
    >(RecurringExpensesController.new);

class RecurringExpensesController
    extends AsyncNotifier<List<RecurringExpense>> {
  @override
  FutureOr<List<RecurringExpense>> build() {
    return ref.watch(recurringExpenseRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(recurringExpenseRepositoryProvider).list(),
    );
  }

  Future<void> toggleActive(String id, bool active) async {
    final previous = state;
    final current = state.value;
    if (current != null) {
      state = AsyncData([
        for (final item in current)
          if (item.id == id)
            RecurringExpense(
              id: item.id,
              name: item.name,
              amount: item.amount,
              category: item.category,
              description: item.description,
              active: active,
              icon: item.icon,
              color: item.color,
              createdAt: item.createdAt,
              updatedAt: item.updatedAt,
            )
          else
            item,
      ]);
    }

    try {
      await ref
          .read(recurringExpenseRepositoryProvider)
          .setActive(id: id, active: active);
      await refresh();
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}
