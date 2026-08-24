import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/error_messages.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Reads the current user from [authControllerProvider] rather than a route
/// `extra` — saving triggers an auth-state change while this page is still
/// mounted, and go_router's `redirect` re-evaluation can drop `extra` on
/// that refresh, which previously crashed this page with a null cast.
class EditSalaryPage extends ConsumerStatefulWidget {
  const EditSalaryPage({super.key});

  @override
  ConsumerState<EditSalaryPage> createState() => _EditSalaryPageState();
}

class _EditSalaryPageState extends ConsumerState<EditSalaryPage> {
  final _formKey = GlobalKey<FormState>();
  late final _currencyController = TextEditingController(
    text: ref.read(authControllerProvider).value?.currency ?? 'TND',
  );
  late int _salaryDay = ref.read(authControllerProvider).value?.salaryDay ?? 1;

  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Period settings'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
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
                  controller: _currencyController,
                  enabled: !_isSaving,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 3,
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    counterText: '',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _salaryDay,
                  decoration: const InputDecoration(
                    labelText: 'Salary day',
                    helperText:
                        'The day your salary period resets each month',
                  ),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) setState(() => _salaryDay = value);
                        },
                  items: [
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
                    ),
                  ),
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
      await ref
          .read(authControllerProvider.notifier)
          .updateFinancialProfile(
            currency: _currencyController.text.trim().toUpperCase(),
            salaryDay: _salaryDay,
          );
      if (mounted) context.pop();
    } catch (error) {
      setState(() {
        _isSaving = false;
        _error = friendlyErrorMessage(error);
      });
    }
  }
}
