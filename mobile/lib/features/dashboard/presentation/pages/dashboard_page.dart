import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_semantic_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../expenses/presentation/widgets/expense_tile.dart';
import '../../data/models/dashboard_summary.dart';
import '../controllers/dashboard_controller.dart';

final _periodDateFormat = DateFormat('d MMM');

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final currency = ref.watch(authControllerProvider).value?.currency ?? 'TND';

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/home-screen.png', height: 40),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expenses/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
        child: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () =>
                ref.read(dashboardControllerProvider.notifier).refresh(),
          ),
          data: (summary) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _PeriodLabel(summary: summary),
                const SizedBox(height: 16),
                _RemainingHero(summary: summary, currency: currency),
                const SizedBox(height: 16),
                _StatRow(summary: summary, currency: currency),
                const SizedBox(height: 24),
                _QuickActions(),
                const SizedBox(height: 24),
                Text(
                  'Recent expenses',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _RecentExpenses(summary: summary, currency: currency),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PeriodLabel extends StatelessWidget {
  const _PeriodLabel({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${_periodDateFormat.format(summary.salaryPeriodStart)} '
        '→ ${_periodDateFormat.format(summary.salaryPeriodEnd)}',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RemainingHero extends StatelessWidget {
  const _RemainingHero({required this.summary, required this.currency});

  final DashboardSummary summary;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final heroColor = summary.overBudget ? colorScheme.error : semantic.success;
    final fraction = (summary.percentageUsed / 100).clamp(0, 1).toDouble();

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            SizedBox(
              width: 176,
              height: 176,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 176,
                    height: 176,
                    child: CircularProgressIndicator(
                      value: fraction,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      valueColor: AlwaysStoppedAnimation(heroColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatMoney(
                          summary.overBudget
                              ? -summary.remaining
                              : summary.remaining,
                          currency,
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary.overBudget ? 'OVER' : 'LEFT',
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${summary.percentageUsed.toStringAsFixed(1)}% used',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.summary, required this.currency});

  final DashboardSummary summary;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Salary',
            amount: summary.salary,
            currency: currency,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Recurring',
            amount: summary.recurringExpensesTotal,
            currency: currency,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Spent',
            amount: summary.totalSpent,
            currency: currency,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.amount,
    required this.currency,
  });

  final String label;
  final num amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatMoney(amount, currency),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickActionChip(
            icon: Icons.add_circle_outline,
            label: 'Add expense',
            onTap: () => context.push('/expenses/new'),
          ),
          const SizedBox(width: 8),
          _QuickActionChip(
            icon: Icons.autorenew,
            label: 'Recurring',
            onTap: () => context.push('/recurring'),
          ),
          const SizedBox(width: 8),
          _QuickActionChip(
            icon: Icons.receipt_long_outlined,
            label: 'All expenses',
            onTap: () => context.push('/expenses'),
          ),
          const SizedBox(width: 8),
          _QuickActionChip(
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () => context.push('/profile'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(icon, size: 18, color: colorScheme.primary),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
      side: BorderSide.none,
    );
  }
}

class _RecentExpenses extends StatelessWidget {
  const _RecentExpenses({required this.summary, required this.currency});

  final DashboardSummary summary;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (summary.recentExpenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: "You're all clear",
          message: 'No expenses recorded for this salary period.',
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: summary.recentExpenses
            .map(
              (expense) => ExpenseTile(
                expense: expense,
                currency: currency,
                onTap: () => context.push('/expenses/${expense.id}'),
              ),
            )
            .toList(),
      ),
    );
  }
}
