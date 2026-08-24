import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class AfterPayApp extends ConsumerWidget {
  const AfterPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'AfterPay',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
    );
  }
}
