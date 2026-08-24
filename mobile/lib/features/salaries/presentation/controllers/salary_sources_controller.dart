import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/salary_source.dart';
import '../../data/repositories/salary_source_repository.dart';

final salarySourcesControllerProvider =
    AsyncNotifierProvider.autoDispose<
      SalarySourcesController,
      List<SalarySource>
    >(SalarySourcesController.new);

class SalarySourcesController extends AsyncNotifier<List<SalarySource>> {
  @override
  FutureOr<List<SalarySource>> build() {
    return ref.watch(salarySourceRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(salarySourceRepositoryProvider).list(),
    );
  }
}
