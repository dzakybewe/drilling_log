import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';

class SensorReaderTile extends StatelessWidget {
  const SensorReaderTile({
    super.key,
    required this.title,
    required this.icon,
    required this.x,
    required this.y,
    required this.z,
    required this.isPreviewing,
    required this.onToggle,
  });

  final String title;
  final IconData icon;
  final double? x;
  final double? y;
  final double? z;
  final bool isPreviewing;
  final VoidCallback onToggle;

  bool get _hasReading => x != null && y != null && z != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: AppDimens.s8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isPreviewing) ...[
                  const SizedBox(width: AppDimens.s8),
                  _LiveBadge(),
                ],
                const Spacer(),
                isPreviewing
                    ? FilledButton.icon(
                        onPressed: onToggle,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, AppDimens.minTouchTarget),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text(AppStrings.btnCaptureSensor),
                      )
                    : OutlinedButton.icon(
                        onPressed: onToggle,
                        icon: const Icon(Icons.sensors, size: 18),
                        label: Text(
                          _hasReading
                              ? AppStrings.btnReadSensorAgain
                              : AppStrings.btnReadSensor,
                        ),
                      ),
              ],
            ),
            const SizedBox(height: AppDimens.s12),
            if (_hasReading)
              Row(
                children: [
                  _AxisChip(label: AppStrings.sensorX, value: x!),
                  const SizedBox(width: AppDimens.s8),
                  _AxisChip(label: AppStrings.sensorY, value: y!),
                  const SizedBox(width: AppDimens.s8),
                  _AxisChip(label: AppStrings.sensorZ, value: z!),
                ],
              )
            else
              Text(
                AppStrings.sensorNoReading,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimens.s4),
        Text(
          AppStrings.sensorLive,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AxisChip extends StatelessWidget {
  const _AxisChip({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s12,
          vertical: AppDimens.s8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value.toStringAsFixed(4),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
