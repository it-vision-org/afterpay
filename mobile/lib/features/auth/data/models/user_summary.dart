class UserSummary {
  const UserSummary({
    required this.id,
    required this.fullName,
    required this.email,
    required this.currency,
    required this.salaryDay,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      currency: json['currency'] as String,
      salaryDay: json['salaryDay'] as int,
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String currency;
  final int salaryDay;
}
