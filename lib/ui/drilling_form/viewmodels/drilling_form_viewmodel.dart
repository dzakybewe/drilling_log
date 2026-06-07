import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/db_constants.dart';
import '../../../data/models/drilling_activity.dart';
import '../../../data/repositories/drilling_repository.dart';
import '../../../data/services/image_service.dart';
import '../../../data/services/sensor_service.dart';

/// Holds form state and orchestrates the repository and image/sensor services.
class DrillingFormViewModel extends ChangeNotifier {
  DrillingFormViewModel(
    this._repository, {
    DrillingActivity? existing,
    ImageService? imageService,
    SensorService? sensorService,
  }) : _imageService = imageService ?? ImageService(),
       _sensorService = sensorService ?? SensorService() {
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
      _imageSizeBytes = _imageService.sizeOf(existing.imagePath);
    }
  }

  final DrillingRepository _repository;
  final ImageService _imageService;
  final SensorService _sensorService;

  int? _id;
  DateTime? _createdAt;

  String _holeId = '';

  DateTime? _date;
  double? _accelX, _accelY, _accelZ;
  double? _gyroX, _gyroY, _gyroZ;
  String? _imagePath;
  String? _completionStatus;

  int? _imageSizeBytes;
  int? _imageOriginalSizeBytes;

  bool _isSaving = false;
  bool _isReadingAccel = false;
  bool _isReadingGyro = false;
  bool _isProcessingImage = false;
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
  bool get isReadingAccel => _isReadingAccel;
  bool get isReadingGyro => _isReadingGyro;
  bool get isProcessingImage => _isProcessingImage;
  bool get hasImage => _imagePath != null && _imagePath!.isNotEmpty;
  int? get imageSizeBytes => _imageSizeBytes;

  /// Original (pre-compression) size of the picked image, when known.
  /// Null in edit mode, since only the compressed file is retained.
  int? get imageOriginalSizeBytes => _imageOriginalSizeBytes;
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

  Future<bool> readAccelerometer() async {
    _isReadingAccel = true;
    notifyListeners();
    try {
      final reading = await _sensorService.readAccelerometer();
      _accelX = reading.x;
      _accelY = reading.y;
      _accelZ = reading.z;
      return true;
    } catch (e, st) {
      log(
        'readAccelerometer failed',
        name: 'DrillingFormVM',
        error: e,
        stackTrace: st,
      );
      return false;
    } finally {
      _isReadingAccel = false;
      notifyListeners();
    }
  }

  Future<bool> readGyroscope() async {
    _isReadingGyro = true;
    notifyListeners();
    try {
      final reading = await _sensorService.readGyroscope();
      _gyroX = reading.x;
      _gyroY = reading.y;
      _gyroZ = reading.z;
      return true;
    } catch (e, st) {
      log(
        'readGyroscope failed',
        name: 'DrillingFormVM',
        error: e,
        stackTrace: st,
      );
      return false;
    } finally {
      _isReadingGyro = false;
      notifyListeners();
    }
  }

  /// Returns false on error; true if saved or cancelled.
  Future<bool> pickImage(ImageSource source) async {
    _isProcessingImage = true;
    notifyListeners();
    try {
      final result = await _imageService.pickAndStore(source);
      if (result == null) return true; // cancelled

      await _imageService.deleteOwned(_imagePath);
      _imagePath = result.path;
      _imageOriginalSizeBytes = result.originalBytes;
      _imageSizeBytes = _imageService.sizeOf(result.path);
      return true;
    } catch (e, st) {
      log(
        'pickImage(source: $source) failed',
        name: 'DrillingFormVM',
        error: e,
        stackTrace: st,
      );
      return false;
    } finally {
      _isProcessingImage = false;
      notifyListeners();
    }
  }

  Future<void> removeImage() async {
    await _imageService.deleteOwned(_imagePath);
    _imagePath = null;
    _imageSizeBytes = null;
    _imageOriginalSizeBytes = null;
    notifyListeners();
  }

  bool validateDate() {
    _dateError = _date == null ? AppStrings.validationDateRequired : null;
    notifyListeners();
    return _date != null;
  }

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
      log(
        'save(status: $status) failed',
        name: 'DrillingFormVM',
        error: e,
        stackTrace: st,
      );
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> saveAsDraft() => save(DbConstants.statusDraft);

  Future<bool> submit() => save(DbConstants.statusSubmitted);
}
