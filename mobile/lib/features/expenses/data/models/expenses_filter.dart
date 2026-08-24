import 'month_selection.dart';

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
  const SpecificPeriodsFilter(this.months);

  final List<MonthSelection> months;
}
