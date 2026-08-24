import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/period_option.dart';

final salaryPeriodRepositoryProvider = Provider<SalaryPeriodRepository>((ref) {
  return SalaryPeriodRepository(ref.watch(dioProvider));
});

class SalaryPeriodRepository {
  SalaryPeriodRepository(this._dio);

  final Dio _dio;

  Future<List<PeriodOption>> recent({int count = 12}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/salary-periods',
        queryParameters: {'count': count},
      );
      return response.data!
          .map((e) => PeriodOption.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
