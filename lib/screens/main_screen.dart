import 'package:flutter/material.dart';
import 'package:rider_tracking/screens/history_screen.dart';
import 'package:rider_tracking/screens/home_screen.dart';
import 'package:rider_tracking/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: [
          const HomeScreen(),
          const HistoryScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Trips'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
