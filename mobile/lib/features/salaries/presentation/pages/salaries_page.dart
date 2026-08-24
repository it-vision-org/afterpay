import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/salary_sources_controller.dart';

class SalariesPage extends ConsumerWidget {
  const SalariesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salariesAsync = ref.watch(salarySourcesControllerProvider);
    final currency = ref.watch(authControllerProvider).value?.currency ?? 'TND';

    return Scaffold(
      appBar: AppBar(title: const Text('Salaries')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/profile/salaries/new'),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(salarySourcesControllerProvider.notifier).refresh(),
        child: salariesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () =>
                ref.read(salarySourcesControllerProvider.notifier).refresh(),
          ),
          data: (salaries) {
            if (salaries.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: EmptyState(
                      icon: Icons.payments_outlined,
                      title: 'No salaries added yet',
                      message:
                          'Add every income that makes up your monthly '
                          'salary — a job, rental income, or more than one.',
                    ),
                  ),
                ],
              );
            }

            final total = salaries.fold<num>(0, (sum, s) => sum + s.amount);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total salary',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          formatMoney(total, currency),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final salary in salaries) ...[
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.12),
                            child: Icon(
                              Icons.payments_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            salary.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: salary.payDay != null
                              ? Text('Pays on the ${salary.payDay}')
                              : null,
                          trailing: Text(
                            formatMoney(salary.amount, currency),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onTap: () => context.push(
                            '/profile/salaries/${salary.id}/edit',
                            extra: salary,
                          ),
                        ),
                        if (salary != salaries.last)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
