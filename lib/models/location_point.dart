class LocationPoint {
  final int? id;
  final String tripId;
  final double latitude, longitude, accuracy, speedMps;
  final double? altitude, heading;
  final DateTime timestamp;
  final bool accepted;
  final String? rejectionReason;

  const LocationPoint({
    this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speedMps,
    this.altitude,
    this.heading,
    required this.timestamp,
    required this.accepted,
    this.rejectionReason,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'trip_id': tripId,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'speed_mps': speedMps,
    'altitude': altitude,
    'heading': heading,
    'timestamp_ms': timestamp.millisecondsSinceEpoch,
    'accepted': accepted ? 1 : 0,
    'rejection_reason': rejectionReason,
  };

  factory LocationPoint.fromMap(Map<String, Object?> m) => LocationPoint(
    id: m['id'] as int?,
    tripId: m['trip_id'] as String,
    latitude: (m['latitude'] as num).toDouble(),
    longitude: (m['longitude'] as num).toDouble(),
    accuracy: (m['accuracy'] as num).toDouble(),
    speedMps: (m['speed_mps'] as num).toDouble(),
    altitude: (m['altitude'] as num?)?.toDouble(),
    heading: (m['heading'] as num?)?.toDouble(),
    timestamp: DateTime.fromMillisecondsSinceEpoch(m['timestamp_ms'] as int),
    accepted: (m['accepted'] as int) == 1,
    rejectionReason: m['rejection_reason'] as String?,
  );
}
