import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/error_messages.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../data/models/salary_source.dart';
import '../../data/repositories/salary_source_repository.dart';
import '../controllers/salary_sources_controller.dart';

class SalarySourceFormPage extends ConsumerStatefulWidget {
  const SalarySourceFormPage({this.salarySource, super.key});

  final SalarySource? salarySource;

  @override
  ConsumerState<SalarySourceFormPage> createState() =>
      _SalarySourceFormPageState();
}

class _SalarySourceFormPageState extends ConsumerState<SalarySourceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.salarySource?.name,
  );
  late final _amountController = TextEditingController(
    text: widget.salarySource?.amount.toString(),
  );
  late int? _payDay = widget.salarySource?.payDay;

  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.salarySource != null;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit salary' : 'Add salary'),
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
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Main job, Rental income',
                  ),
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
                DropdownButtonFormField<int?>(
                  initialValue: _payDay,
                  decoration: const InputDecoration(
                    labelText: 'Pay day (optional)',
                    helperText: 'Just a reminder — does not affect your salary period',
                  ),
                  onChanged: _isSaving
                      ? null
                      : (value) => setState(() => _payDay = value),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    for (var day = 1; day <= 31; day++)
                      DropdownMenuItem(value: day, child: Text('$day')),
                  ],
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
                      : Text(_isEditing ? 'Save changes' : 'Add salary'),
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
      final repo = ref.read(salarySourceRepositoryProvider);
      final name = _nameController.text.trim();
      final amount = num.parse(_amountController.text);

      if (_isEditing) {
        await repo.update(
          id: widget.salarySource!.id,
          name: name,
          amount: amount,
          payDay: _payDay,
        );
      } else {
        await repo.create(name: name, amount: amount, payDay: _payDay);
      }

      ref.invalidate(salarySourcesControllerProvider);
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
        title: const Text('Delete this salary?'),
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
          .read(salarySourceRepositoryProvider)
          .delete(widget.salarySource!.id);
      ref.invalidate(salarySourcesControllerProvider);
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
