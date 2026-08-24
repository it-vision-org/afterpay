import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/error_view.dart';
import '../../data/models/period_option.dart';
import '../controllers/expenses_controller.dart';

/// Lets the user pick one or more specific salary periods (not necessarily
/// contiguous) to filter the expenses list by.
class SpecificPeriodPickerSheet extends ConsumerStatefulWidget {
  const SpecificPeriodPickerSheet({required this.preselected, super.key});

  final List<PeriodOption> preselected;

  @override
  ConsumerState<SpecificPeriodPickerSheet> createState() =>
      _SpecificPeriodPickerSheetState();
}

class _SpecificPeriodPickerSheetState
    extends ConsumerState<SpecificPeriodPickerSheet> {
  late final Set<DateTime> _selectedStarts = widget.preselected
      .map((p) => p.start)
      .toSet();

  @override
  Widget build(BuildContext context) {
    final periodsAsync = ref.watch(recentSalaryPeriodsProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Choose periods',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: _selectedStarts.isEmpty
                            ? null
                            : () => Navigator.of(context).pop(
                                periodsAsync.value
                                    ?.where(
                                      (p) => _selectedStarts.contains(p.start),
                                    )
                                    .toList(),
                              ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: periodsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => ErrorView(
                      error: error,
                      onRetry: () => ref.invalidate(recentSalaryPeriodsProvider),
                    ),
                    data: (periods) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: periods.length,
                        itemBuilder: (context, index) {
                          final period = periods[index];
                          final selected = _selectedStarts.contains(
                            period.start,
                          );
                          return CheckboxListTile(
                            value: selected,
                            title: Text(period.label),
                            onChanged: (value) => setState(() {
                              if (value ?? false) {
                                _selectedStarts.add(period.start);
                              } else {
                                _selectedStarts.remove(period.start);
                              }
                            }),
                          );
                        },
                      );
                    },
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
