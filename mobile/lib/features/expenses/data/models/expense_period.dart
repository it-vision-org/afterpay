enum ExpensePeriod {
  current,
  previous,
  all;

  String get apiValue => switch (this) {
    ExpensePeriod.current => 'CURRENT',
    ExpensePeriod.previous => 'PREVIOUS',
    ExpensePeriod.all => 'ALL',
  };
}
