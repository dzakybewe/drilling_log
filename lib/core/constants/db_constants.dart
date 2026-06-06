/// Database, table, and column name constants plus persisted status values.
class DbConstants {
  DbConstants._();

  static const String dbName = 'drilling_log.db';
  static const int dbVersion = 1;

  static const String table = 'drilling_activities';

  // Columns
  static const String colId = 'id';
  static const String colHoleId = 'hole_id';
  static const String colDate = 'date';
  static const String colAccelX = 'accel_x';
  static const String colAccelY = 'accel_y';
  static const String colAccelZ = 'accel_z';
  static const String colGyroX = 'gyro_x';
  static const String colGyroY = 'gyro_y';
  static const String colGyroZ = 'gyro_z';
  static const String colImagePath = 'image_path';
  static const String colStatus = 'status';
  static const String colCompletionStatus = 'completion_status';
  static const String colCreatedAt = 'created_at';

  // Lifecycle status values
  static const String statusDraft = 'draft';
  static const String statusSubmitted = 'submitted';
}
