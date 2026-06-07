import '../../core/constants/db_constants.dart';

/// A single drilling activity record persisted in SQLite.
class DrillingActivity {
  DrillingActivity({
    this.id,
    required this.holeId,
    required this.date,
    this.accelX,
    this.accelY,
    this.accelZ,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    this.imagePath,
    required this.status,
    this.completionStatus,
    required this.createdAt,
  });

  int? id;
  String holeId;
  DateTime date;
  double? accelX, accelY, accelZ;
  double? gyroX, gyroY, gyroZ;
  String? imagePath; // local file path
  String status; // 'draft' or 'submitted'
  String? completionStatus; // 'Complete' or 'Not Complete'
  DateTime createdAt;

  /// Serializes to a map keyed by database column names.
  Map<String, Object?> toMap() {
    return {
      DbConstants.colId: id,
      DbConstants.colHoleId: holeId,
      DbConstants.colDate: date.toIso8601String(),
      DbConstants.colAccelX: accelX,
      DbConstants.colAccelY: accelY,
      DbConstants.colAccelZ: accelZ,
      DbConstants.colGyroX: gyroX,
      DbConstants.colGyroY: gyroY,
      DbConstants.colGyroZ: gyroZ,
      DbConstants.colImagePath: imagePath,
      DbConstants.colStatus: status,
      DbConstants.colCompletionStatus: completionStatus,
      DbConstants.colCreatedAt: createdAt.toIso8601String(),
    };
  }

  /// Builds an instance from a database row map.
  factory DrillingActivity.fromMap(Map<String, Object?> map) {
    return DrillingActivity(
      id: map[DbConstants.colId] as int?,
      holeId: map[DbConstants.colHoleId] as String,
      date: DateTime.parse(map[DbConstants.colDate] as String),
      accelX: (map[DbConstants.colAccelX] as num?)?.toDouble(),
      accelY: (map[DbConstants.colAccelY] as num?)?.toDouble(),
      accelZ: (map[DbConstants.colAccelZ] as num?)?.toDouble(),
      gyroX: (map[DbConstants.colGyroX] as num?)?.toDouble(),
      gyroY: (map[DbConstants.colGyroY] as num?)?.toDouble(),
      gyroZ: (map[DbConstants.colGyroZ] as num?)?.toDouble(),
      imagePath: map[DbConstants.colImagePath] as String?,
      status: map[DbConstants.colStatus] as String,
      completionStatus: map[DbConstants.colCompletionStatus] as String?,
      createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
    );
  }

  DrillingActivity copyWith({
    int? id,
    String? holeId,
    DateTime? date,
    double? accelX,
    double? accelY,
    double? accelZ,
    double? gyroX,
    double? gyroY,
    double? gyroZ,
    String? imagePath,
    String? status,
    String? completionStatus,
    DateTime? createdAt,
  }) {
    return DrillingActivity(
      id: id ?? this.id,
      holeId: holeId ?? this.holeId,
      date: date ?? this.date,
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      gyroX: gyroX ?? this.gyroX,
      gyroY: gyroY ?? this.gyroY,
      gyroZ: gyroZ ?? this.gyroZ,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      completionStatus: completionStatus ?? this.completionStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get hasAccelerometer =>
      accelX != null && accelY != null && accelZ != null;

  bool get hasGyroscope => gyroX != null && gyroY != null && gyroZ != null;
}
