import 'package:flutter/material.dart';
import 'package:rider_tracking/screens/create_account_screen.dart';
import 'package:rider_tracking/screens/main_screen.dart';
import 'package:rider_tracking/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(), pass = TextEditingController();
  bool busy = false;
  String? error;

  Future<void> login() async {
    if (email.text.trim().isEmpty || pass.text.isEmpty) {
      setState(() => error = 'Enter email and password');
      return;
    }
    setState(() => busy = true);
    await AuthService.login(email.text.trim(), pass.text);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.two_wheeler, size: 64),
              const SizedBox(height: 12),
              const Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: busy ? null : login,
                child: Text(busy ? 'Signing in...' : 'Login'),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateAccountScreen(),
                  ),
                ),
                child: const Text('Create account'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
