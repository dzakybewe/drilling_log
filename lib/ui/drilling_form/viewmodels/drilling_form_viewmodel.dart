import 'dart:developer';

import 'package:flutter/foundation.dart';

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
  String? _dateError;

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
