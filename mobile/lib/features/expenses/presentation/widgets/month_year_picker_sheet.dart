import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/month_selection.dart';

final _monthAbbrFormat = DateFormat('MMM');

/// Lets the user pick one or more calendar months, navigating freely between
/// years, with a shortcut to select every month of the displayed year at
/// once. Selections persist while navigating between years, so the result
/// can span multiple years.
class MonthYearPickerSheet extends StatefulWidget {
  const MonthYearPickerSheet({required this.preselected, super.key});

  final List<MonthSelection> preselected;

  @override
  State<MonthYearPickerSheet> createState() => _MonthYearPickerSheetState();
}

class _MonthYearPickerSheetState extends State<MonthYearPickerSheet> {
  late final Set<MonthSelection> _selected = widget.preselected.toSet();
  late int _displayedYear = widget.preselected.isEmpty
      ? DateTime.now().year
      : widget.preselected.map((m) => m.year).reduce((a, b) => a > b ? a : b);

  bool get _wholeYearSelected {
    for (var month = 1; month <= 12; month++) {
      if (!_selected.contains(MonthSelection(year: _displayedYear, month: month))) {
        return false;
      }
    }
    return true;
  }

  void _toggleWholeYear(bool select) {
    setState(() {
      for (var month = 1; month <= 12; month++) {
        final selection = MonthSelection(year: _displayedYear, month: month);
        if (select) {
          _selected.add(selection);
        } else {
          _selected.remove(selection);
        }
      }
    });
  }

  void _toggleMonth(MonthSelection selection) {
    setState(() {
      if (_selected.contains(selection)) {
        _selected.remove(selection);
      } else {
        _selected.add(selection);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose months',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    if (_selected.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(_selected.clear),
                        child: const Text('Clear'),
                      ),
                    TextButton(
                      onPressed: _selected.isEmpty
                          ? null
                          : () => Navigator.of(context).pop(_selected.toList()),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _displayedYear--),
                ),
                SizedBox(
                  width: 96,
                  child: Text(
                    '$_displayedYear',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _displayedYear++),
                ),
              ],
            ),
            const SizedBox(height: 4),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text('Select all of $_displayedYear'),
              value: _wholeYearSelected,
              onChanged: (value) => _toggleWholeYear(value ?? false),
            ),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                for (var month = 1; month <= 12; month++)
                  _MonthCell(
                    label: _monthAbbrFormat.format(DateTime(_displayedYear, month)),
                    selected: _selected.contains(
                      MonthSelection(year: _displayedYear, month: month),
                    ),
                    onTap: () => _toggleMonth(
                      MonthSelection(year: _displayedYear, month: month),
                    ),
                    colorScheme: colorScheme,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
