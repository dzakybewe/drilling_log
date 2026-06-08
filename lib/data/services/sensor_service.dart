import 'package:sensors_plus/sensors_plus.dart';

class SensorReading {
  const SensorReading({required this.x, required this.y, required this.z});

  final double x;
  final double y;
  final double z;
}

/// Accelerometer / gyroscope access via sensors_plus.
class SensorService {
  static const Duration _timeout = Duration(seconds: 2);

  /// One-shot read, also used to check whether a sensor is available.
  Future<SensorReading> readAccelerometer() async {
    final event = await accelerometerEventStream().first.timeout(_timeout);
    return SensorReading(x: event.x, y: event.y, z: event.z);
  }

  Future<SensorReading> readGyroscope() async {
    final event = await gyroscopeEventStream().first.timeout(_timeout);
    return SensorReading(x: event.x, y: event.y, z: event.z);
  }

  /// Sensor streams. 
  Stream<SensorReading> accelerometerStream() => accelerometerEventStream()
      .map((e) => SensorReading(x: e.x, y: e.y, z: e.z));

  Stream<SensorReading> gyroscopeStream() =>
      gyroscopeEventStream().map((e) => SensorReading(x: e.x, y: e.y, z: e.z));
}
