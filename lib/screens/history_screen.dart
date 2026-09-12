import 'package:flutter/material.dart';
import 'package:rider_tracking/data/app_database.dart';
import 'package:rider_tracking/models/trip.dart';
import 'package:rider_tracking/screens/trip_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Trip> trips = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final x = await AppDatabase.instance.allTrips();
    if (mounted) setState(() => trips = x);
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip History')),
      body: trips.isEmpty
          ? const Center(child: Text('No trips yet'))
          : ListView.builder(
              itemCount: trips.length,
              itemBuilder: (_, i) {
                final t = trips[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      t.status == TripStatus.active
                          ? Icons.play_arrow
                          : Icons.check,
                    ),
                  ),
                  title: Text(
                    '${t.startAddress} → ${t.endAddress}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${t.status.name} • ${(t.totalDistanceMeters / 1000).toStringAsFixed(2)} km',
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripDetailsScreen(trip: t),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
