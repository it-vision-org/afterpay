import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../models/expense_period.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(dioProvider));
});

final _dateFormat = DateFormat('yyyy-MM-dd');

class ExpenseRepository {
  ExpenseRepository(this._dio);

  final Dio _dio;

  Future<List<Expense>> list({ExpensePeriod? period}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/expenses',
        queryParameters: {if (period != null) 'period': period.apiValue},
      );
      return response.data!
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Expense> get(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/expenses/$id');
      return Expense.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Expense> create({
    required String name,
    required num amount,
    required Category category,
    required DateTime expenseDate,
    String? note,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/expenses',
        data: {
          'name': name,
          'amount': amount,
          'category': category.apiValue,
          'expenseDate': _dateFormat.format(expenseDate),
          'note': note,
        },
      );
      return Expense.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Expense> update({
    required String id,
    required String name,
    required num amount,
    required Category category,
    required DateTime expenseDate,
    String? note,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/expenses/$id',
        data: {
          'name': name,
          'amount': amount,
          'category': category.apiValue,
          'expenseDate': _dateFormat.format(expenseDate),
          'note': note,
        },
      );
      return Expense.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete<void>('/expenses/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
