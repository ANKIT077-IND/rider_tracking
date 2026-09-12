import 'package:flutter/material.dart';
import 'package:rider_tracking/screens/login_screen.dart';
import 'package:rider_tracking/screens/settings_screen.dart';
import 'package:rider_tracking/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '', email = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await AuthService.name(), e = await AuthService.email();
    if (mounted) {
      setState(() {
        name = n;
        email = e;
      });
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 48)),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(email, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
