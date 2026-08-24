class PeriodOption {
  const PeriodOption({required this.start, required this.end, required this.label});

  factory PeriodOption.fromJson(Map<String, dynamic> json) {
    return PeriodOption(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      label: json['label'] as String,
    );
  }

  final DateTime start;
  final DateTime end;
  final String label;
}
