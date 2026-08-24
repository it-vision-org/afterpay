import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/models/expense.dart';
import '../../data/models/expense_period.dart';
import '../../data/repositories/expense_repository.dart';

final expensesPeriodFilterProvider = StateProvider.autoDispose<ExpensePeriod>(
  (ref) => ExpensePeriod.current,
);

final expensesControllerProvider =
    AsyncNotifierProvider.autoDispose<ExpensesController, List<Expense>>(
      ExpensesController.new,
    );

class ExpensesController extends AsyncNotifier<List<Expense>> {
  @override
  FutureOr<List<Expense>> build() {
    final period = ref.watch(expensesPeriodFilterProvider);
    return ref.watch(expenseRepositoryProvider).list(period: period);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(expenseRepositoryProvider)
          .list(period: ref.read(expensesPeriodFilterProvider)),
    );
  }
}

final expenseDetailProvider = FutureProvider.autoDispose
    .family<Expense, String>((ref, id) {
      return ref.watch(expenseRepositoryProvider).get(id);
    });
