import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          SwitchListTile(
            value: true,
            onChanged: null,
            title: Text('GPS tracking'),
            subtitle: Text('Location tracking is controlled by active trips.'),
          ),
          ListTile(
            title: Text('Offline storage'),
            subtitle: Text('Trips and accepted GPS points are stored locally.'),
          ),
          ListTile(
            title: Text('Background tracking'),
            subtitle: Text(
              'Android foreground service / iOS Core Location configuration is included.',
            ),
          ),
        ],
      ),
    );
  }
}
