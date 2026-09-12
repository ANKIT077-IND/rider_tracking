import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/location_filter.dart';
import '../data/app_database.dart';
import '../models/location_point.dart';
import '../models/trip.dart';

class TrackingService {
  TrackingService._();

  static final instance = TrackingService._();
  final service = FlutterBackgroundService();
  StreamSubscription<Position>? _sub;
  Future<void> _queue = Future.value();

  Future<void> initialize() async {
    const channel = AndroidNotificationChannel(
      'rider_tracking',
      'Rider Tracking',
      description: 'Active rider trip tracking',
      importance: Importance.low,
    );
    final n = FlutterLocalNotificationsPlugin();
    await n
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        autoStartOnBoot: true,
        isForegroundMode: true,
        notificationChannelId: 'rider_tracking',
        initialNotificationTitle: 'Rider Tracking',
        initialNotificationContent: 'Trip tracking',
        foregroundServiceNotificationId: 4201,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<void> start() => service.startService();

  Future<void> stop() async => service.invoke('stop');

  static Future<bool> onIosBackground(ServiceInstance service) async => true;

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    final prefs = await SharedPreferences.getInstance();
    final tripId = prefs.getString('active_trip_id');
    if (tripId == null) {
      service.stopSelf();
      return;
    }
    final t = TrackingService._();
    if (service is AndroidServiceInstance) service.setAsForegroundService();
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );
    t._sub = Geolocator.getPositionStream(locationSettings: settings).listen((
      p,
    ) {
      t._queue = t._queue
          .then((_) async {
            final db = AppDatabase.instance;
            final trip = await db.getTrip(tripId);
            if (trip == null || trip.status != TripStatus.active) return;
            final prev = await db.lastAcceptedPoint(tripId);
            final d = LocationFilter.evaluate(
              current: p,
              previousAccepted: prev,
            );
            final point = LocationPoint(
              tripId: tripId,
              latitude: p.latitude,
              longitude: p.longitude,
              accuracy: p.accuracy,
              speedMps: d.validSpeedMps,
              altitude: p.altitude,
              heading: p.heading,
              timestamp: p.timestamp ?? DateTime.now(),
              accepted: d.accepted,
              rejectionReason: d.reason,
            );
            await db.insertPoint(point);
            if (!d.accepted) {
              service.invoke('trip_update', {
                'accepted': false,
                'reason': d.reason,
              });
              return;
            }
            var distance = trip.totalDistanceMeters;
            if (prev != null) {
              distance += Geolocator.distanceBetween(
                prev.latitude,
                prev.longitude,
                p.latitude,
                p.longitude,
              );
            }
            final max = d.validSpeedMps > trip.maxSpeedMps
                ? d.validSpeedMps
                : trip.maxSpeedMps;
            await db.updateTrip(
              trip.copyWith(
                totalDistanceMeters: distance,
                currentSpeedMps: d.validSpeedMps,
                maxSpeedMps: max,
              ),
            );
            if (service is AndroidServiceInstance) {
              service.setForegroundNotificationInfo(
                title: 'Trip in progress',
                content:
                    '${(distance / 1000).toStringAsFixed(2)} km • ${(d.validSpeedMps * 3.6).toStringAsFixed(0)} km/h',
              );
            }
            service.invoke('trip_update', {
              'accepted': true,
              'tripId': tripId,
              'lat': p.latitude,
              'lng': p.longitude,
              'speedMps': d.validSpeedMps,
              'distanceMeters': distance,
              'maxSpeedMps': max,
            });
          })
          .catchError((e) {
            service.invoke('trip_error', {'message': e.toString()});
          });
    });
    service.on('stop').listen((_) async {
      await t._sub?.cancel();
      await t._queue;
      service.stopSelf();
    });
  }
}
