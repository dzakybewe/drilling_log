import 'package:sqflite/sqflite.dart';

import '../../core/constants/db_constants.dart';
import '../models/drilling_activity.dart';
import '../services/database_helper.dart';

/// Provides full CRUD access to [DrillingActivity] records in SQLite.
class DrillingRepository {
  DrillingRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<Database> get _db => _databaseHelper.database;

  /// Inserts a new activity and returns the generated id.
  Future<int> insert(DrillingActivity activity) async {
    final db = await _db;
    final map = activity.toMap()..remove(DbConstants.colId);
    return db.insert(DbConstants.table, map);
  }

  /// Updates an existing activity (matched by id). Returns affected row count.
  Future<int> update(DrillingActivity activity) async {
    final db = await _db;
    return db.update(
      DbConstants.table,
      activity.toMap(),
      where: '${DbConstants.colId} = ?',
      whereArgs: [activity.id],
    );
  }

  /// Deletes the activity with [id]. Returns affected row count.
  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete(
      DbConstants.table,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  /// Returns all activities with the given lifecycle [status], newest first.
  Future<List<DrillingActivity>> getByStatus(String status) async {
    final db = await _db;
    final rows = await db.query(
      DbConstants.table,
      where: '${DbConstants.colStatus} = ?',
      whereArgs: [status],
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return rows.map(DrillingActivity.fromMap).toList();
  }

  /// Returns every activity, newest first.
  Future<List<DrillingActivity>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      DbConstants.table,
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return rows.map(DrillingActivity.fromMap).toList();
  }

  /// Returns the activity with [id], or null if not found.
  Future<DrillingActivity?> getById(int id) async {
    final db = await _db;
    final rows = await db.query(
      DbConstants.table,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DrillingActivity.fromMap(rows.first);
  }
}
