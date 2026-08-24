import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/error_messages.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../expenses/data/models/category.dart';
import '../../../expenses/presentation/widgets/category_picker.dart';
import '../../data/models/recurring_expense.dart';
import '../../data/repositories/recurring_expense_repository.dart';
import '../controllers/recurring_expenses_controller.dart';

class RecurringExpenseFormPage extends ConsumerStatefulWidget {
  const RecurringExpenseFormPage({this.recurringExpense, super.key});

  final RecurringExpense? recurringExpense;

  @override
  ConsumerState<RecurringExpenseFormPage> createState() =>
      _RecurringExpenseFormPageState();
}

class _RecurringExpenseFormPageState
    extends ConsumerState<RecurringExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.recurringExpense?.name,
  );
  late final _amountController = TextEditingController(
    text: widget.recurringExpense?.amount.toString(),
  );
  late final _descriptionController = TextEditingController(
    text: widget.recurringExpense?.description,
  );

  late Category _category = widget.recurringExpense?.category ?? Category.other;
  late bool _active = widget.recurringExpense?.active ?? true;

  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.recurringExpense != null;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit recurring expense' : 'Add recurring expense'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  autofocus: !_isEditing,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  enabled: !_isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    final amount = num.tryParse(value ?? '');
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CategoryPicker(
                  selected: _category,
                  enabled: !_isSaving,
                  onChanged: (value) => setState(() => _category = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isSaving,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  subtitle: const Text(
                    'Included in the current salary period',
                  ),
                  value: _active,
                  onChanged: _isSaving
                      ? null
                      : (value) => setState(() => _active = value),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Add recurring expense'),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _isSaving ? null : _delete,
                    child: const Text('Delete'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final repo = ref.read(recurringExpenseRepositoryProvider);
      final name = _nameController.text.trim();
      final amount = num.parse(_amountController.text);
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();

      if (_isEditing) {
        await repo.update(
          id: widget.recurringExpense!.id,
          name: name,
          amount: amount,
          category: _category,
          description: description,
          active: _active,
        );
      } else {
        await repo.create(
          name: name,
          amount: amount,
          category: _category,
          description: description,
          active: _active,
        );
      }

      ref.invalidate(recurringExpensesControllerProvider);
      ref.invalidate(dashboardControllerProvider);
      if (mounted) context.pop();
    } catch (error) {
      setState(() {
        _isSaving = false;
        _error = friendlyErrorMessage(error);
      });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete recurring expense?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(recurringExpenseRepositoryProvider)
          .delete(widget.recurringExpense!.id);
      ref.invalidate(recurringExpensesControllerProvider);
      ref.invalidate(dashboardControllerProvider);
      if (mounted) context.pop();
    } catch (error) {
      setState(() {
        _isSaving = false;
        _error = friendlyErrorMessage(error);
      });
    }
  }
}
