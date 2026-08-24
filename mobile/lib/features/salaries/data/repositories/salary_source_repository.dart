import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/salary_source.dart';

final salarySourceRepositoryProvider = Provider<SalarySourceRepository>((ref) {
  return SalarySourceRepository(ref.watch(dioProvider));
});

class SalarySourceRepository {
  SalarySourceRepository(this._dio);

  final Dio _dio;

  Future<List<SalarySource>> list() async {
    try {
      final response = await _dio.get<List<dynamic>>('/salary-sources');
      return response.data!
          .map((e) => SalarySource.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SalarySource> get(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/salary-sources/$id',
      );
      return SalarySource.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SalarySource> create({
    required String name,
    required num amount,
    int? payDay,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/salary-sources',
        data: {'name': name, 'amount': amount, 'payDay': payDay},
      );
      return SalarySource.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SalarySource> update({
    required String id,
    required String name,
    required num amount,
    int? payDay,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/salary-sources/$id',
        data: {'name': name, 'amount': amount, 'payDay': payDay},
      );
      return SalarySource.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete<void>('/salary-sources/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
