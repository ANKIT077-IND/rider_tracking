import 'package:flutter/material.dart';
import 'package:rider_tracking/models/trip.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({required this.trip, super.key});

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip details')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${trip.status.name}'),
            Text('From: ${trip.startAddress}'),
            Text('To: ${trip.endAddress}'),
            Text(
              'Distance: ${(trip.totalDistanceMeters / 1000).toStringAsFixed(2)} km',
            ),
            Text(
              'Maximum speed: ${(trip.maxSpeedMps * 3.6).toStringAsFixed(1)} km/h',
            ),
            Text('Started: ${trip.startTime}'),
          ],
        ),
      ),
    );
  }
}
