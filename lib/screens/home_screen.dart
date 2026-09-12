import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rider_tracking/data/app_database.dart';
import 'package:rider_tracking/models/trip.dart';
import 'package:rider_tracking/screens/settings_screen.dart';
import 'package:rider_tracking/services/tracking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final start = TextEditingController(), end = TextEditingController();
  Trip? trip;
  LatLng? sp, ep, rp;
  final route = <LatLng>[];
  Set<Marker> markers = {};
  GoogleMapController? map;
  StreamSubscription? sub, err;
  String msg = 'Set start and end locations';
  String? error;

  @override
  void initState() {
    super.initState();
    _restore();
    sub = TrackingService.instance.service.on('trip_update').listen((e) {
      if (!mounted || e == null) return;
      if (e['accepted'] == true) {
        final lat = (e['lat'] as num?)?.toDouble(),
            lng = (e['lng'] as num?)?.toDouble();
        if (lat == null || lng == null) return;
        final p = LatLng(lat, lng);
        setState(() {
          rp = p;
          route.add(p);
          msg = 'Tracking active';
        });
        map?.animateCamera(CameraUpdate.newLatLng(p));
        _reload();
      } else if (e['accepted'] == false)
        setState(() {
          msg = 'GPS sample rejected: ${e['reason'] ?? 'invalid'}';
        });
    });
    err = TrackingService.instance.service.on('trip_error').listen((e) {
      if (mounted) setState(() => error = e?['message']?.toString());
    });
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getString('active_trip_id');
    if (id == null) return;
    final t = await AppDatabase.instance.getTrip(id);
    if (t == null || !mounted) return;
    final pts = await AppDatabase.instance.acceptedPoints(id);
    setState(() {
      trip = t;
      sp = LatLng(t.startLat, t.startLng);
      ep = LatLng(t.endLat, t.endLng);
      route.addAll(pts.map((x) => LatLng(x.latitude, x.longitude)));
      rp = route.isEmpty ? sp : route.last;
      start.text = t.startAddress;
      end.text = t.endAddress;
    });
  }

  Future<void> _reload() async {
    if (trip == null) return;
    final t = await AppDatabase.instance.getTrip(trip!.id);
    if (t != null && mounted) setState(() => trip = t);
  }

  Future<bool> _perm() async {
    await Geolocator.isLocationServiceEnabled();
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.denied ||
        p == LocationPermission.deniedForever) {
      setState(() => error = 'Location permission is required.');
      return false;
    }
    return true;
  }

  Future<LatLng?> _geo(String s) async {
    try {
      List<Location> p = await locationFromAddress(s);

      return p.isEmpty ? null : LatLng(p.first.latitude, p.first.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<void> _set(bool first) async {
    final p = await _geo(first ? start.text : end.text);
    if (p == null) {
      setState(() => error = 'Location not found.');
      return;
    }
    setState(() {
      error = null;
      if (first) {
        sp = p;
        markers = {
          ...markers,
          Marker(
            markerId: const MarkerId('start'),
            position: p,
            infoWindow: const InfoWindow(title: 'Start'),
          ),
        };
      } else {
        ep = p;
        markers = {
          ...markers,
          Marker(
            markerId: const MarkerId('end'),
            position: p,
            infoWindow: const InfoWindow(title: 'End'),
          ),
        };
      }
    });
    map?.animateCamera(CameraUpdate.newLatLngZoom(p, 14));
  }

  Future<void> _currentStart() async {
    if (!await _perm()) return;
    final p = await Geolocator.getCurrentPosition();
    final ll = LatLng(p.latitude, p.longitude);
    start.text =
        '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}';
    setState(() {
      sp = ll;
      markers = {
        ...markers,
        Marker(
          markerId: const MarkerId('start'),
          position: ll,
          infoWindow: const InfoWindow(title: 'Start'),
        ),
      };
    });
    map?.animateCamera(CameraUpdate.newLatLngZoom(ll, 15));
  }

  Future<void> _start() async {
    if (trip?.status == TripStatus.active) {
      setState(() => error = 'Trip already active.');
      return;
    }
    if (sp == null || ep == null) {
      setState(() => error = 'Set both locations first.');
      return;
    }
    if (!await _perm()) return;
    final id = const Uuid().v4();
    final t = Trip(
      id: id,
      requestId: const Uuid().v4(),
      startAddress: start.text.trim(),
      endAddress: end.text.trim(),
      startLat: sp!.latitude,
      startLng: sp!.longitude,
      endLat: ep!.latitude,
      endLng: ep!.longitude,
      startTime: DateTime.now(),
      status: TripStatus.active,
    );
    await AppDatabase.instance.insertTrip(t);
    final p = await SharedPreferences.getInstance();
    await p.setString('active_trip_id', id);
    await TrackingService.instance.start();
    setState(() {
      trip = t;
      route.clear();
      error = null;
      msg = 'Trip started';
    });
  }

  Future<void> _end() async {
    if (trip == null || trip!.status != TripStatus.active) return;
    await TrackingService.instance.stop();
    final p = await SharedPreferences.getInstance();
    await p.remove('active_trip_id');
    final t = trip!.copyWith(
      endTime: DateTime.now(),
      currentSpeedMps: 0,
      status: TripStatus.ended,
    );
    await AppDatabase.instance.updateTrip(t);
    setState(() => trip = t);
  }

  @override
  void dispose() {
    sub?.cancel();
    err?.cancel();
    start.dispose();
    end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final active = trip?.status == TripStatus.active;
    final target = rp ?? sp ?? const LatLng(28.6139, 77.2090);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Tracking'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: target, zoom: 12),
              myLocationEnabled: true,
              markers: markers,
              polylines: {
                Polyline(polylineId: const PolylineId('route'), points: route),
              },
              onMapCreated: (x) => map = x,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: start,
                    enabled: !active,
                    decoration: InputDecoration(
                      labelText: 'Start location',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: active ? null : () => _set(true),
                        icon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: active ? null : _currentStart,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use current location'),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: end,
                    enabled: !active,
                    decoration: InputDecoration(
                      labelText: 'End location',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: active ? null : () => _set(false),
                        icon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  Text(msg),
                  Row(
                    children: [
                      Expanded(
                        child: _metric(
                          'Speed',
                          '${((trip?.currentSpeedMps ?? 0) * 3.6).toStringAsFixed(1)} km/h',
                        ),
                      ),
                      Expanded(
                        child: _metric(
                          'Max',
                          '${((trip?.maxSpeedMps ?? 0) * 3.6).toStringAsFixed(1)} km/h',
                        ),
                      ),
                      Expanded(
                        child: _metric(
                          'Distance',
                          '${((trip?.totalDistanceMeters ?? 0) / 1000).toStringAsFixed(2)} km',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: active ? null : _start,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Trip'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: active ? _end : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('End Trip'),
                        ),
                      ),
                    ],
                  ),
                  if (trip != null) Text('Status: ${trip!.status.name}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String a, String b) => Card(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(a),
          Text(b, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
