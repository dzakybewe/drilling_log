import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
      // Read the size of the already-saved image (edit mode).
      _imageSizeBytes = _readSizeSync(existing.imagePath);
    }
  }

  final DrillingRepository _repository;
  final ImagePicker _picker = ImagePicker();

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

  /// How long to wait for a single sensor sample before giving up.
  static const Duration _sensorTimeout = Duration(seconds: 2);

  /// Compression targets: around 225-275 KB by keeping quality as high as still fits.
  static const int _maxImageBytes = 250 * 1024;

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

  /// Picks an image from [source], compresses it to under 250 KB, stores it in
  /// the app documents directory, and keeps the resulting file path.
  /// Returns false on error; returns true if the user simply cancelled.
  Future<bool> pickImage(ImageSource source) async {
    _isProcessingImage = true;
    notifyListeners();
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked == null) return true; // user cancelled — not an error

      final originalSize = await File(picked.path).length();
      // Only compress when the original exceeds the cap. Re-encoding an
      // already-small image can actually make it larger, so keep it as-is.
      final savedPath = originalSize <= _maxImageBytes
          ? await _copyToDocuments(picked.path)
          : await _compressAndSave(picked.path);
      if (savedPath == null) return false;

      // Replace any previous image we created, then adopt the new one.
      await _deleteOwnedImage(_imagePath);
      _imagePath = savedPath;
      _imageOriginalSizeBytes = originalSize;
      _loadImageSize();
      return true;
    } catch (e, st) {
      log('pickImage(source: $source) failed',
          name: 'DrillingFormVM', error: e, stackTrace: st);
      return false;
    } finally {
      _isProcessingImage = false;
      notifyListeners();
    }
  }

  /// Removes the current image (and deletes the file if we own it).
  Future<void> removeImage() async {
    await _deleteOwnedImage(_imagePath);
    _imagePath = null;
    _imageSizeBytes = null;
    _imageOriginalSizeBytes = null;
    notifyListeners();
  }

  /// Synchronously reads a file's byte size, or null if it doesn't exist.
  int? _readSizeSync(String? path) {
    if (path == null || path.isEmpty) return null;
    try {
      final file = File(path);
      return file.existsSync() ? file.lengthSync() : null;
    } catch (_) {
      return null;
    }
  }

  /// Updates the displayed size from the current image file.
  void _loadImageSize() {
    _imageSizeBytes = _readSizeSync(_imagePath);
    notifyListeners();
  }

  /// Copies an already-small source image into the documents directory
  /// without re-encoding it. Returns the saved path, or null on failure.
  Future<String?> _copyToDocuments(String srcPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = p.extension(srcPath).isNotEmpty ? p.extension(srcPath) : '.jpg';
    final targetPath = p.join(
      dir.path,
      'drilling_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await File(srcPath).copy(targetPath);
    return targetPath;
  }

  /// Compresses [srcPath] to land just under [_maxImageBytes] (≈250 KB target).
  /// Within each resolution tier it binary-searches the JPEG quality to find
  /// the highest quality whose output still fits, so the result lands as close
  /// to the cap as the image allows (typically the 225-250 KB band). If even
  /// the lowest quality is too big, it scales the resolution down and retries.
  /// Returns the saved file path, or null if compression failed.
  Future<String?> _compressAndSave(String srcPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final targetPath = p.join(
      dir.path,
      'drilling_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    int minWidth = 1920;
    int minHeight = 1080;
    Uint8List? smallest; // fallback if nothing ever fits under the cap

    for (var tier = 0; tier < 4; tier++) {
      var lo = 10;
      var hi = 95;
      Uint8List? bestFit; // largest result that still fits at this resolution

      while (lo <= hi) {
        final quality = (lo + hi) ~/ 2;
        final bytes = await FlutterImageCompress.compressWithFile(
          srcPath,
          minWidth: minWidth,
          minHeight: minHeight,
          quality: quality,
        );
        if (bytes == null) return null;

        if (smallest == null || bytes.length < smallest.length) {
          smallest = bytes;
        }

        if (bytes.length <= _maxImageBytes) {
          bestFit = bytes; // fits — try a higher quality to get closer to cap
          lo = quality + 1;
        } else {
          hi = quality - 1; // too big — lower the quality
        }
      }

      if (bestFit != null) {
        await File(targetPath).writeAsBytes(bestFit, flush: true);
        return targetPath;
      }

      // Nothing fit even at the lowest quality; shrink resolution and retry.
      minWidth = (minWidth * 0.7).round();
      minHeight = (minHeight * 0.7).round();
    }

    // Could not get under the cap; persist the smallest attempt produced.
    if (smallest == null) return null;
    await File(targetPath).writeAsBytes(smallest, flush: true);
    return targetPath;
  }

  /// Deletes an image file only if it lives in our documents directory, so we
  /// never touch the user's original gallery files.
  Future<void> _deleteOwnedImage(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      if (!p.isWithin(dir.path, path)) return;
      final file = File(path);
      if (file.existsSync()) await file.delete();
    } catch (e, st) {
      log('_deleteOwnedImage failed',
          name: 'DrillingFormVM', error: e, stackTrace: st);
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
