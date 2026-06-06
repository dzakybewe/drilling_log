import 'package:flutter/material.dart';

import '../constants/db_constants.dart';

/// Muted color pair (background + foreground) for a status badge.
class StatusColor {
  const StatusColor({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

/// Maps a persisted lifecycle status to its muted badge colors.
class StatusColors {
  StatusColors._();

  // Muted amber for drafts (in-progress, local only).
  static const StatusColor _draft = StatusColor(
    background: Color(0xFFFBEFD3),
    foreground: Color(0xFF8A5A00),
  );

  // Muted teal/green for submitted (finalized).
  static const StatusColor _submitted = StatusColor(
    background: Color(0xFFD8ECE4),
    foreground: Color(0xFF1C6B53),
  );

  static StatusColor of(String status) {
    return status == DbConstants.statusSubmitted ? _submitted : _draft;
  }
}
