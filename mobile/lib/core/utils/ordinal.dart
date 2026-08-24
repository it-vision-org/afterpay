/// Formats a day-of-month as an ordinal, e.g. `1` -> `1st`, `25` -> `25th`.
String ordinal(int day) {
  if (day % 100 >= 11 && day % 100 <= 13) {
    return '${day}th';
  }
  return switch (day % 10) {
    1 => '${day}st',
    2 => '${day}nd',
    3 => '${day}rd',
    _ => '${day}th',
  };
}
