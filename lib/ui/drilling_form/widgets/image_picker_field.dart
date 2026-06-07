import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';

class ImagePickerField extends StatelessWidget {
  const ImagePickerField({
    super.key,
    required this.imagePath,
    required this.sizeBytes,
    required this.originalSizeBytes,
    required this.isProcessing,
    required this.onPick,
    required this.onRemove,
  });

  final String? imagePath;
  final int? sizeBytes;
  final int? originalSizeBytes;
  final bool isProcessing;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  bool get _hasImage => imagePath != null && imagePath!.isNotEmpty;

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
                Icon(
                  Icons.photo_camera_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppDimens.s8),
                Text(
                  AppStrings.fieldImage,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.s12),
            if (isProcessing)
              const SizedBox(
                height: AppDimens.imagePreviewHeight,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasImage)
              _Preview(
                path: imagePath!,
                sizeBytes: sizeBytes,
                originalSizeBytes: originalSizeBytes,
                onReplace: onPick,
                onRemove: onRemove,
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text(AppStrings.btnPickImage),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.path,
    required this.sizeBytes,
    required this.originalSizeBytes,
    required this.onReplace,
    required this.onRemove,
  });

  final String path;
  final int? sizeBytes;
  final int? originalSizeBytes;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  /// Formats a byte count as KB (or MB for larger files).
  String _formatSize(int bytes) {
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(2)} MB';
  }

  /// Builds the size label. Shows "before → after" when compression actually
  /// shrank the file; otherwise just the single file size.
  String _sizeLabel() {
    final compressed = sizeBytes!;
    final original = originalSizeBytes;
    if (original == null || original <= 0 || compressed >= original) {
      return '${AppStrings.imageFileSize}: ${_formatSize(compressed)}';
    }
    return '${AppStrings.imageFileSize}: ${_formatSize(original)} '
        '→ ${_formatSize(compressed)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          child: Image.file(
            File(path),
            width: double.infinity,
            height: AppDimens.imagePreviewHeight,
            fit: BoxFit.contain,
          ),
        ),
        if (sizeBytes != null) ...[
          const SizedBox(height: AppDimens.s12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.s12,
                vertical: AppDimens.s4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.compress,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimens.s4),
                  Text(
                    _sizeLabel(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppDimens.s12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReplace,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(AppStrings.btnReplaceImage),
              ),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text(AppStrings.btnRemoveImage),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
