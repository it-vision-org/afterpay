import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/utils/ordinal.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final totalSalary = ref.watch(dashboardControllerProvider).value?.salary;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(
              user != null && user.fullName.isNotEmpty
                  ? user.fullName[0].toUpperCase()
                  : '?',
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'ACCOUNT',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Full name'),
                  subtitle: Text(user?.fullName ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: user == null
                      ? null
                      : () => context.push(
                          '/profile/edit-name',
                          extra: user.fullName,
                        ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(
                    Icons.email_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('Email'),
                  subtitle: Text(user?.email ?? ''),
                  enabled: false,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Password'),
                  subtitle: const Text('••••••••'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/change-password'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'FINANCIAL',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Salaries'),
                  subtitle: Text(
                    totalSalary == null || user == null
                        ? ''
                        : formatMoney(totalSalary, user.currency),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/salaries'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('Salary day'),
                  subtitle: Text(
                    user == null
                        ? ''
                        : '${ordinal(user.salaryDay)} of every month',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/edit-salary'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.currency_exchange_outlined),
                  title: const Text('Currency'),
                  subtitle: Text(user?.currency ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/edit-salary'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
