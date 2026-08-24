import 'period_option.dart';

sealed class ExpensesFilter {
  const ExpensesFilter();
}

class CurrentPeriodFilter extends ExpensesFilter {
  const CurrentPeriodFilter();
}

class AllExpensesFilter extends ExpensesFilter {
  const AllExpensesFilter();
}

class SpecificPeriodsFilter extends ExpensesFilter {
  const SpecificPeriodsFilter(this.periods);

  final List<PeriodOption> periods;
}
