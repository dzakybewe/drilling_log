import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/drilling_activity.dart';
import '../../data/repositories/drilling_repository.dart';
import 'viewmodels/drilling_form_viewmodel.dart';
import 'widgets/date_field.dart';
import 'widgets/status_dropdown.dart';

/// Entry point for the Drilling Form screen. Provides its own ViewModel,
/// seeded with an existing activity (edit mode) when passed via route args.
class DrillingFormScreen extends StatelessWidget {
  const DrillingFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final existing =
        ModalRoute.of(context)?.settings.arguments as DrillingActivity?;

    return ChangeNotifierProvider(
      create: (context) => DrillingFormViewModel(
        context.read<DrillingRepository>(),
        existing: existing,
      ),
      child: const _DrillingFormView(),
    );
  }
}

class _DrillingFormView extends StatefulWidget {
  const _DrillingFormView();

  @override
  State<_DrillingFormView> createState() => _DrillingFormViewState();
}

class _DrillingFormViewState extends State<_DrillingFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _holeIdController;

  @override
  void initState() {
    super.initState();
    _holeIdController = TextEditingController(
      text: context.read<DrillingFormViewModel>().holeId,
    );
  }

  @override
  void dispose() {
    _holeIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(DrillingFormViewModel viewModel) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.date ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      viewModel.setDate(picked);
    }
  }

  /// Validates both the Form (Hole ID) and the date field.
  bool _validate(DrillingFormViewModel viewModel) {
    final formValid = _formKey.currentState?.validate() ?? false;
    final dateValid = viewModel.validateDate();
    return formValid && dateValid;
  }

  Future<void> _handleSave({
    required DrillingFormViewModel viewModel,
    required Future<bool> Function() action,
    required String successMessage,
  }) async {
    if (!_validate(viewModel)) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await action();
    if (!mounted) return;

    if (success) {
      navigator.pop(true);
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.snackSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DrillingFormViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.isEditing
              ? AppStrings.formTitleEdit
              : AppStrings.formTitleNew,
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.btnSaveDraft,
            icon: const Icon(Icons.save_outlined),
            onPressed: viewModel.isSaving
                ? null
                : () => _handleSave(
                      viewModel: viewModel,
                      action: viewModel.saveAsDraft,
                      successMessage: AppStrings.snackDraftSaved,
                    ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppDimens.s16),
                  children: [
                    DateField(
                      date: viewModel.date,
                      errorText: viewModel.dateError,
                      onTap: () => _pickDate(viewModel),
                    ),
                    const SizedBox(height: AppDimens.s16),
                    TextFormField(
                      controller: _holeIdController,
                      onChanged: viewModel.setHoleId,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: AppStrings.fieldHoleId,
                        hintText: AppStrings.fieldHoleIdHint,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.validationHoleIdRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimens.s16),
                    StatusDropdown(
                      value: viewModel.completionStatus,
                      onChanged: viewModel.setCompletionStatus,
                    ),
                  ],
                ),
              ),
            ),
            _SubmitBar(
              isSaving: viewModel.isSaving,
              onSubmit: () => _handleSave(
                viewModel: viewModel,
                action: viewModel.submit,
                successMessage: AppStrings.snackSubmitted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width submit button pinned to the bottom of the form.
class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.isSaving, required this.onSubmit});

  final bool isSaving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.s16),
      child: FilledButton(
        onPressed: isSaving ? null : onSubmit,
        child: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(AppStrings.btnSubmit),
      ),
    );
  }
}
