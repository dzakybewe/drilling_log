import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/db_constants.dart';
import '../../../core/theme/status_colors.dart';

/// A small pill badge representing an activity's lifecycle status.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  String get _label => status == DbConstants.statusSubmitted
      ? AppStrings.badgeSubmitted
      : AppStrings.badgeDraft;

  @override
  Widget build(BuildContext context) {
    final colors = StatusColors.of(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s12,
        vertical: AppDimens.s4,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Text(
        _label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
