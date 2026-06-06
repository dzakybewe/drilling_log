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
    required this.isReading,
    required this.onRead,
  });

  final String title;
  final IconData icon;
  final double? x;
  final double? y;
  final double? z;
  final bool isReading;
  final VoidCallback onRead;

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
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: isReading ? null : onRead,
                  icon: isReading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sensors, size: 18),
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
