import 'package:flutter/material.dart';
import 'package:rider_tracking/screens/login_screen.dart';
import 'package:rider_tracking/screens/main_screen.dart';
import 'package:rider_tracking/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final ok = await AuthService.loggedIn();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ok ? const MainScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.two_wheeler, size: 72),
            SizedBox(height: 16),
            Text(
              'Rider Tracking',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
