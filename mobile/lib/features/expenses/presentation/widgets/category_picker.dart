import 'package:flutter/material.dart';

import '../../data/models/category.dart';

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final Category selected;
  final ValueChanged<Category> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Category>(
      initialValue: selected,
      decoration: const InputDecoration(labelText: 'Category'),
      onChanged: enabled
          ? (value) {
              if (value != null) onChanged(value);
            }
          : null,
      items: Category.values
          .map(
            (category) => DropdownMenuItem(
              value: category,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(category.label),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
