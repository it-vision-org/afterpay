import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/password_reset_otp_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_email_args.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/data/models/expense.dart';
import '../../features/expenses/presentation/pages/expense_detail_page.dart';
import '../../features/expenses/presentation/pages/expense_form_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/edit_name_page.dart';
import '../../features/profile/presentation/pages/edit_salary_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/recurring/data/models/recurring_expense.dart';
import '../../features/recurring/presentation/pages/recurring_expense_form_page.dart';
import '../../features/recurring/presentation/pages/recurring_expenses_page.dart';
import '../../features/salaries/data/models/salary_source.dart';
import '../../features/salaries/presentation/pages/salaries_page.dart';
import '../../features/salaries/presentation/pages/salary_source_form_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../widgets/main_shell.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier();
  ref.listen(
    authControllerProvider,
    (previous, next) => refreshNotifier.notify(),
  );
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isInitializing = authState.isLoading && !authState.hasValue;
      final location = state.matchedLocation;

      if (isInitializing) {
        return location == '/splash' ? null : '/splash';
      }

      final isLoggedIn = authState.value != null;
      final isAuthRoute =
          location == '/login' ||
          location == '/register' ||
          location == '/verify-email' ||
          location == '/forgot-password' ||
          location == '/password-reset/verify' ||
          location == '/password-reset/new-password';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && (isAuthRoute || location == '/splash')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) =>
            VerifyEmailPage(args: state.extra as VerifyEmailArgs),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/password-reset/verify',
        name: 'password-reset-verify',
        builder: (context, state) =>
            PasswordResetOtpPage(email: state.extra as String),
      ),
      GoRoute(
        path: '/password-reset/new-password',
        name: 'password-reset-new-password',
        builder: (context, state) =>
            NewPasswordPage(resetToken: state.extra as String),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                name: 'expenses',
                builder: (context, state) => const ExpensesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recurring',
                name: 'recurring',
                builder: (context, state) => const RecurringExpensesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/expenses/new',
        name: 'expense-new',
        builder: (context, state) => const ExpenseFormPage(),
      ),
      GoRoute(
        path: '/expenses/:id/edit',
        name: 'expense-edit',
        builder: (context, state) =>
            ExpenseFormPage(expense: state.extra as Expense?),
      ),
      GoRoute(
        path: '/expenses/:id',
        name: 'expense-detail',
        builder: (context, state) =>
            ExpenseDetailPage(expenseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/recurring/new',
        name: 'recurring-new',
        builder: (context, state) => const RecurringExpenseFormPage(),
      ),
      GoRoute(
        path: '/recurring/:id/edit',
        name: 'recurring-edit',
        builder: (context, state) => RecurringExpenseFormPage(
          recurringExpense: state.extra as RecurringExpense?,
        ),
      ),
      GoRoute(
        path: '/profile/edit-name',
        name: 'profile-edit-name',
        builder: (context, state) => const EditNamePage(),
      ),
      GoRoute(
        path: '/profile/edit-salary',
        name: 'profile-edit-salary',
        builder: (context, state) => const EditSalaryPage(),
      ),
      GoRoute(
        path: '/profile/change-password',
        name: 'profile-change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/profile/salaries',
        name: 'salaries',
        builder: (context, state) => const SalariesPage(),
      ),
      GoRoute(
        path: '/profile/salaries/new',
        name: 'salary-new',
        builder: (context, state) => const SalarySourceFormPage(),
      ),
      GoRoute(
        path: '/profile/salaries/:id/edit',
        name: 'salary-edit',
        builder: (context, state) => SalarySourceFormPage(
          salarySource: state.extra as SalarySource?,
        ),
      ),
    ],
  );
});
