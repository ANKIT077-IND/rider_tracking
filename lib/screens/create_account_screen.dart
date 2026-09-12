import 'package:flutter/material.dart';
import 'package:rider_tracking/screens/main_screen.dart';
import 'package:rider_tracking/services/auth_service.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final name = TextEditingController(),
      email = TextEditingController(),
      pass = TextEditingController(),
      confirm = TextEditingController();
  String? error;

  Future<void> create() async {
    if (name.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        pass.text.length < 6) {
      setState(
        () => error =
            'Enter all details; password must be at least 6 characters.',
      );
      return;
    }
    if (pass.text != confirm.text) {
      setState(() => error = 'Passwords do not match.');
      return;
    }
    await AuthService.register(name.text.trim(), email.text.trim(), pass.text);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: email,
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
            const SizedBox(height: 12),
            TextField(
              controller: confirm,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                border: OutlineInputBorder(),
              ),
            ),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: create,
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
