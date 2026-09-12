import 'package:geolocator/geolocator.dart';

import '../models/location_point.dart';

class LocationDecision {
  final bool accepted;
  final String? reason;
  final double validSpeedMps;

  const LocationDecision(this.accepted, this.reason, this.validSpeedMps);
}

class LocationFilter {
  static const maxAccuracy = 80.0, maxSpeed = 55.0, maxGap = 120.0;

  static LocationDecision evaluate({
    required Position current,
    LocationPoint? previousAccepted,
  }) {
    final speed = current.speed.isFinite && current.speed >= 0
        ? current.speed
        : 0.0;
    if (!current.accuracy.isFinite ||
        current.accuracy <= 0 ||
        current.accuracy > maxAccuracy) {
      return LocationDecision(false, 'Poor GPS accuracy', speed);
    }
    if (speed > maxSpeed) {
      return LocationDecision(false, 'Unrealistic GPS speed', 0);
    }
    if (previousAccepted == null) return LocationDecision(true, null, speed);
    final now = current.timestamp ?? DateTime.now();
    final seconds =
        now.difference(previousAccepted.timestamp).inMilliseconds / 1000.0;
    if (seconds <= 0 || seconds > maxGap) {
      return LocationDecision(true, null, speed);
    }
    final d = Geolocator.distanceBetween(
      previousAccepted.latitude,
      previousAccepted.longitude,
      current.latitude,
      current.longitude,
    );
    if (d / seconds > maxSpeed) {
      return LocationDecision(false, 'GPS position jump detected', speed);
    }
    return LocationDecision(true, null, speed);
  }
}
