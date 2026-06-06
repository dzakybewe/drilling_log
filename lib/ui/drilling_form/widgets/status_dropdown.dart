import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class StatusDropdown extends StatelessWidget {
  const StatusDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: AppStrings.fieldStatus,
      ),
      hint: const Text(AppStrings.fieldStatusHint),
      items: const [
        DropdownMenuItem(
          value: AppStrings.statusComplete,
          child: Text(AppStrings.statusComplete),
        ),
        DropdownMenuItem(
          value: AppStrings.statusNotComplete,
          child: Text(AppStrings.statusNotComplete),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
