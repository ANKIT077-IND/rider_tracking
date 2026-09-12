import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/location_point.dart';
import '../models/trip.dart';

class AppDatabase {
  AppDatabase._();

  static final instance = AppDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'rider_tracking.db'),
      version: 1,
      onCreate: (db, v) async {
        await db.execute(
          'CREATE TABLE trips(id TEXT PRIMARY KEY,request_id TEXT NOT NULL,start_address TEXT NOT NULL,end_address TEXT NOT NULL,start_lat REAL NOT NULL,start_lng REAL NOT NULL,end_lat REAL NOT NULL,end_lng REAL NOT NULL,start_time_ms INTEGER NOT NULL,end_time_ms INTEGER,total_distance_m REAL NOT NULL,current_speed_mps REAL NOT NULL,max_speed_mps REAL NOT NULL,status TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE location_points(id INTEGER PRIMARY KEY AUTOINCREMENT,trip_id TEXT NOT NULL,latitude REAL NOT NULL,longitude REAL NOT NULL,accuracy REAL NOT NULL,speed_mps REAL NOT NULL,altitude REAL,heading REAL,timestamp_ms INTEGER NOT NULL,accepted INTEGER NOT NULL,rejection_reason TEXT)',
        );
      },
    );
    return _db!;
  }

  Future<void> insertTrip(Trip t) async => (await database).insert(
    'trips',
    t.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  Future<Trip?> getTrip(String id) async {
    final r = await (await database).query(
      'trips',
      where: 'id=?',
      whereArgs: [id],
      limit: 1,
    );
    return r.isEmpty ? null : Trip.fromMap(r.first);
  }

  Future<List<Trip>> allTrips() async {
    final r = await (await database).query(
      'trips',
      orderBy: 'start_time_ms DESC',
    );
    return r.map(Trip.fromMap).toList();
  }

  Future<Trip?> activeTrip() async {
    final r = await (await database).query(
      'trips',
      where: 'status=?',
      whereArgs: ['active'],
      limit: 1,
    );
    return r.isEmpty ? null : Trip.fromMap(r.first);
  }

  Future<void> updateTrip(Trip t) async => (await database).update(
    'trips',
    t.toMap(),
    where: 'id=?',
    whereArgs: [t.id],
  );

  Future<void> insertPoint(LocationPoint p) async =>
      (await database).insert('location_points', p.toMap());

  Future<LocationPoint?> lastAcceptedPoint(String id) async {
    final r = await (await database).query(
      'location_points',
      where: 'trip_id=? AND accepted=1',
      whereArgs: [id],
      orderBy: 'timestamp_ms DESC',
      limit: 1,
    );
    return r.isEmpty ? null : LocationPoint.fromMap(r.first);
  }

  Future<List<LocationPoint>> acceptedPoints(String id) async {
    final r = await (await database).query(
      'location_points',
      where: 'trip_id=? AND accepted=1',
      whereArgs: [id],
      orderBy: 'timestamp_ms ASC',
    );
    return r.map(LocationPoint.fromMap).toList();
  }
}
