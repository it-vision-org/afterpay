import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../expenses/data/models/category.dart';
import '../models/recurring_expense.dart';

final recurringExpenseRepositoryProvider = Provider<RecurringExpenseRepository>((
  ref,
) {
  return RecurringExpenseRepository(ref.watch(dioProvider));
});

class RecurringExpenseRepository {
  RecurringExpenseRepository(this._dio);

  final Dio _dio;

  Future<List<RecurringExpense>> list({bool? active}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/recurring-expenses',
        queryParameters: {'active': ?active},
      );
      return response.data!
          .map((e) => RecurringExpense.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<RecurringExpense> get(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/recurring-expenses/$id',
      );
      return RecurringExpense.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<RecurringExpense> create({
    required String name,
    required num amount,
    required Category category,
    String? description,
    bool active = true,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/recurring-expenses',
        data: {
          'name': name,
          'amount': amount,
          'category': category.apiValue,
          'description': description,
          'active': active,
        },
      );
      return RecurringExpense.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<RecurringExpense> update({
    required String id,
    required String name,
    required num amount,
    required Category category,
    String? description,
    required bool active,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/recurring-expenses/$id',
        data: {
          'name': name,
          'amount': amount,
          'category': category.apiValue,
          'description': description,
          'active': active,
        },
      );
      return RecurringExpense.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<RecurringExpense> setActive({
    required String id,
    required bool active,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/recurring-expenses/$id/active',
        data: {'active': active},
      );
      return RecurringExpense.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete<void>('/recurring-expenses/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
