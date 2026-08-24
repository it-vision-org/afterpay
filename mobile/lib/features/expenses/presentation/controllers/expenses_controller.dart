import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/models/expense.dart';
import '../../data/models/expenses_filter.dart';
import '../../data/repositories/expense_repository.dart';

final expensesFilterProvider = StateProvider.autoDispose<ExpensesFilter>(
  (ref) => const CurrentPeriodFilter(),
);

final expensesControllerProvider =
    AsyncNotifierProvider.autoDispose<ExpensesController, List<Expense>>(
      ExpensesController.new,
    );

class ExpensesController extends AsyncNotifier<List<Expense>> {
  @override
  FutureOr<List<Expense>> build() {
    final filter = ref.watch(expensesFilterProvider);
    return ref.watch(expenseRepositoryProvider).list(filter: filter);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(expenseRepositoryProvider)
          .list(filter: ref.read(expensesFilterProvider)),
    );
  }
}

final expenseDetailProvider = FutureProvider.autoDispose
    .family<Expense, String>((ref, id) {
      return ref.watch(expenseRepositoryProvider).get(id);
    });
