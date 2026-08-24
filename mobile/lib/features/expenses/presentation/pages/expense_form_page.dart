import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/error_messages.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';
import '../controllers/expenses_controller.dart';
import '../widgets/category_picker.dart';

class ExpenseFormPage extends ConsumerStatefulWidget {
  const ExpenseFormPage({this.expense, super.key});

  final Expense? expense;

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.expense?.name);
  late final _amountController = TextEditingController(
    text: widget.expense?.amount.toString(),
  );
  late final _noteController = TextEditingController(text: widget.expense?.note);

  late Category _category = widget.expense?.category ?? Category.other;
  late DateTime _date = widget.expense?.expenseDate ?? DateTime.now();

  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.expense != null;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit expense' : 'Add expense'),
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
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('d MMM yyyy').format(_date)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _isSaving ? null : _pickDate,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  enabled: !_isSaving,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                  ),
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
                      : Text(_isEditing ? 'Save changes' : 'Add expense'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
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
      final repo = ref.read(expenseRepositoryProvider);
      final name = _nameController.text.trim();
      final amount = num.parse(_amountController.text);
      final note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim();

      if (_isEditing) {
        await repo.update(
          id: widget.expense!.id,
          name: name,
          amount: amount,
          category: _category,
          expenseDate: _date,
          note: note,
        );
        ref.invalidate(expenseDetailProvider(widget.expense!.id));
      } else {
        await repo.create(
          name: name,
          amount: amount,
          category: _category,
          expenseDate: _date,
          note: note,
        );
      }

      ref.invalidate(expensesControllerProvider);
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
