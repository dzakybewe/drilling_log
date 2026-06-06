import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/constants/db_constants.dart';

/// Singleton that owns the SQLite database connection and schema creation.
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  /// Lazily opens (and caches) the database instance.
  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, DbConstants.dbName);

    return openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.table} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colHoleId} TEXT NOT NULL,
        ${DbConstants.colDate} TEXT NOT NULL,
        ${DbConstants.colAccelX} REAL,
        ${DbConstants.colAccelY} REAL,
        ${DbConstants.colAccelZ} REAL,
        ${DbConstants.colGyroX} REAL,
        ${DbConstants.colGyroY} REAL,
        ${DbConstants.colGyroZ} REAL,
        ${DbConstants.colImagePath} TEXT,
        ${DbConstants.colStatus} TEXT NOT NULL,
        ${DbConstants.colCompletionStatus} TEXT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL
      )
    ''');
  }

  /// Closes the database; primarily useful for tests.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
