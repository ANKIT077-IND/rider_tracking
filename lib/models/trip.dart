enum TripStatus { idle, active, ended }

class Trip {
  final String id, requestId, startAddress, endAddress;
  final double startLat, startLng, endLat, endLng;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistanceMeters, currentSpeedMps, maxSpeedMps;
  final TripStatus status;

  const Trip({
    required this.id,
    required this.requestId,
    required this.startAddress,
    required this.endAddress,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.startTime,
    this.endTime,
    this.totalDistanceMeters = 0,
    this.currentSpeedMps = 0,
    this.maxSpeedMps = 0,
    required this.status,
  });

  Trip copyWith({
    DateTime? endTime,
    double? totalDistanceMeters,
    double? currentSpeedMps,
    double? maxSpeedMps,
    TripStatus? status,
  }) => Trip(
    id: id,
    requestId: requestId,
    startAddress: startAddress,
    endAddress: endAddress,
    startLat: startLat,
    startLng: startLng,
    endLat: endLat,
    endLng: endLng,
    startTime: startTime,
    endTime: endTime ?? this.endTime,
    totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
    currentSpeedMps: currentSpeedMps ?? this.currentSpeedMps,
    maxSpeedMps: maxSpeedMps ?? this.maxSpeedMps,
    status: status ?? this.status,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'request_id': requestId,
    'start_address': startAddress,
    'end_address': endAddress,
    'start_lat': startLat,
    'start_lng': startLng,
    'end_lat': endLat,
    'end_lng': endLng,
    'start_time_ms': startTime.millisecondsSinceEpoch,
    'end_time_ms': endTime?.millisecondsSinceEpoch,
    'total_distance_m': totalDistanceMeters,
    'current_speed_mps': currentSpeedMps,
    'max_speed_mps': maxSpeedMps,
    'status': status.name,
  };

  factory Trip.fromMap(Map<String, Object?> m) => Trip(
    id: m['id'] as String,
    requestId: m['request_id'] as String,
    startAddress: m['start_address'] as String,
    endAddress: m['end_address'] as String,
    startLat: (m['start_lat'] as num).toDouble(),
    startLng: (m['start_lng'] as num).toDouble(),
    endLat: (m['end_lat'] as num).toDouble(),
    endLng: (m['end_lng'] as num).toDouble(),
    startTime: DateTime.fromMillisecondsSinceEpoch(m['start_time_ms'] as int),
    endTime: m['end_time_ms'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(m['end_time_ms'] as int),
    totalDistanceMeters: (m['total_distance_m'] as num?)?.toDouble() ?? 0,
    currentSpeedMps: (m['current_speed_mps'] as num?)?.toDouble() ?? 0,
    maxSpeedMps: (m['max_speed_mps'] as num?)?.toDouble() ?? 0,
    status: TripStatus.values.byName(m['status'] as String),
  );
}
