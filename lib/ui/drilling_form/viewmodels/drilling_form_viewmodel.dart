import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/db_constants.dart';
import '../../../data/models/drilling_activity.dart';
import '../../../data/repositories/drilling_repository.dart';

/// Drives the Drilling Form screen
class DrillingFormViewModel extends ChangeNotifier {
  DrillingFormViewModel(
    this._repository, {
    DrillingActivity? existing,
  }) {
    if (existing != null) {
      _id = existing.id;
      _createdAt = existing.createdAt;
      _holeId = existing.holeId;
      _date = existing.date;
      _accelX = existing.accelX;
      _accelY = existing.accelY;
      _accelZ = existing.accelZ;
      _gyroX = existing.gyroX;
      _gyroY = existing.gyroY;
      _gyroZ = existing.gyroZ;
      _imagePath = existing.imagePath;
      _completionStatus = existing.completionStatus;
    }
  }

  final DrillingRepository _repository;

  int? _id;
  DateTime? _createdAt;

  String _holeId = '';

  DateTime? _date;
  double? _accelX, _accelY, _accelZ;
  double? _gyroX, _gyroY, _gyroZ;
  String? _imagePath;
  String? _completionStatus;

  bool _isSaving = false;
  bool _isReadingAccel = false;
  bool _isReadingGyro = false;
  String? _dateError;

  /// How long to wait for a single sensor sample before giving up.
  static const Duration _sensorTimeout = Duration(seconds: 2);

  /// Getters
  bool get isEditing => _id != null;
  String get holeId => _holeId;
  DateTime? get date => _date;
  double? get accelX => _accelX;
  double? get accelY => _accelY;
  double? get accelZ => _accelZ;
  double? get gyroX => _gyroX;
  double? get gyroY => _gyroY;
  double? get gyroZ => _gyroZ;
  String? get imagePath => _imagePath;
  String? get completionStatus => _completionStatus;
  bool get isSaving => _isSaving;
  bool get isReadingAccel => _isReadingAccel;
  bool get isReadingGyro => _isReadingGyro;
  String? get dateError => _dateError;
  /// End of Getters

  void setHoleId(String value) {
    _holeId = value;
  }

  void setDate(DateTime value) {
    _date = value;
    _dateError = null;
    notifyListeners();
  }

  void setCompletionStatus(String? value) {
    _completionStatus = value;
    notifyListeners();
  }

  /// Reads a single accelerometer sample (x, y, z in m/s²).
  /// Returns false if the sensor is unavailable or times out.
  Future<bool> readAccelerometer() async {
    _isReadingAccel = true;
    notifyListeners();
    try {
      final event =
          await accelerometerEventStream().first.timeout(_sensorTimeout);
      _accelX = event.x;
      _accelY = event.y;
      _accelZ = event.z;
      return true;
    } catch (e, st) {
      log('readAccelerometer failed',
          name: 'DrillingFormVM', error: e, stackTrace: st);
      return false;
    } finally {
      _isReadingAccel = false;
      notifyListeners();
    }
  }

  /// Reads a single gyroscope sample (x, y, z in rad/s).
  /// Returns false if the sensor is unavailable or times out.
  Future<bool> readGyroscope() async {
    _isReadingGyro = true;
    notifyListeners();
    try {
      final event =
          await gyroscopeEventStream().first.timeout(_sensorTimeout);
      _gyroX = event.x;
      _gyroY = event.y;
      _gyroZ = event.z;
      return true;
    } catch (e, st) {
      log('readGyroscope failed',
          name: 'DrillingFormVM', error: e, stackTrace: st);
      return false;
    } finally {
      _isReadingGyro = false;
      notifyListeners();
    }
  }

  /// Validates the date field (Hole ID is validated by the Form itself).
  /// Returns true when a date has been selected.
  bool validateDate() {
    _dateError = _date == null ? AppStrings.validationDateRequired : null;
    notifyListeners();
    return _date != null;
  }

  /// Saves the form with [status]. Returns true on success.
  Future<bool> save(String status) async {
    _isSaving = true;
    notifyListeners();

    try {
      final activity = DrillingActivity(
        id: _id,
        holeId: _holeId.trim(),
        date: _date!,
        accelX: _accelX,
        accelY: _accelY,
        accelZ: _accelZ,
        gyroX: _gyroX,
        gyroY: _gyroY,
        gyroZ: _gyroZ,
        imagePath: _imagePath,
        status: status,
        completionStatus: _completionStatus,
        createdAt: _createdAt ?? DateTime.now(),
      );

      if (isEditing) {
        await _repository.update(activity);
      } else {
        await _repository.insert(activity);
      }
      return true;
    } catch (e, st) {
      log('save(status: $status) failed',
          name: 'DrillingFormVM', error: e, stackTrace: st);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> saveAsDraft() => save(DbConstants.statusDraft);

  Future<bool> submit() => save(DbConstants.statusSubmitted);
}
