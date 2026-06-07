import 'package:sensors_plus/sensors_plus.dart';

class SensorReading {
  const SensorReading({required this.x, required this.y, required this.z});

  final double x;
  final double y;
  final double z;
}

/// One-shot accelerometer / gyroscope reads via sensors_plus.
class SensorService {
  static const Duration _timeout = Duration(seconds: 2);

  Future<SensorReading> readAccelerometer() async {
    final event = await accelerometerEventStream().first.timeout(_timeout);
    return SensorReading(x: event.x, y: event.y, z: event.z);
  }

  Future<SensorReading> readGyroscope() async {
    final event = await gyroscopeEventStream().first.timeout(_timeout);
    return SensorReading(x: event.x, y: event.y, z: event.z);
  }
}
