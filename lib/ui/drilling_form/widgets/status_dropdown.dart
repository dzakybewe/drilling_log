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
    return DropdownMenu<String>(
      expandedInsets: EdgeInsets.zero,
      initialSelection: value,
      onSelected: onChanged,
      label: const Text(AppStrings.fieldStatus),
      hintText: AppStrings.fieldStatusHint,
      dropdownMenuEntries: const [
        DropdownMenuEntry(
          value: AppStrings.statusComplete,
          label: AppStrings.statusComplete,
        ),
        DropdownMenuEntry(
          value: AppStrings.statusNotComplete,
          label: AppStrings.statusNotComplete,
        ),
      ],
    );
  }
}
