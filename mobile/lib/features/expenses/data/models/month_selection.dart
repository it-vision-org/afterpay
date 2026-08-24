import 'package:intl/intl.dart';

final _monthYearFormat = DateFormat('MMMM yyyy');

/// A single calendar month picked from the month/year calendar in the
/// expenses filter. The backend resolves whichever salary period ends in
/// this month from just the 1st of the month — see [periodStartDate].
class MonthSelection {
  const MonthSelection({required this.year, required this.month});

  /// The 1st of this month always falls inside the salary period whose end
  /// date lands in this month, regardless of the user's salary day — so it's
  /// a safe, salary-day-agnostic value to send as `periodStart`.
  DateTime get periodStartDate => DateTime(year, month, 1);

  String get label => _monthYearFormat.format(DateTime(year, month));

  final int year;
  final int month;

  @override
  bool operator ==(Object other) =>
      other is MonthSelection && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}
