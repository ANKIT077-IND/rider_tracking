import 'package:flutter/material.dart';
import 'package:rider_tracking/screens/splash_screen.dart';
import 'package:rider_tracking/services/tracking_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TrackingService.instance.initialize();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Rider Tracking',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    home: const SplashScreen(),
  );
}
