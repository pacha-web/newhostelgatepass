import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; // For Timer

class UniversalSignIn extends StatefulWidget {
  const UniversalSignIn({super.key});

  @override
  State<UniversalSignIn> createState() => _UniversalSignInState();
}

class _UniversalSignInState extends State<UniversalSignIn> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';
  int _failedAttempts = 0;
  DateTime? _blockTime;
  Timer? _timer;

  void _handleLogin(BuildContext context) {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Check if the user is currently blocked
    if (_blockTime != null && DateTime.now().isBefore(_blockTime!)) {
      final remainingTime = _blockTime!.difference(DateTime.now()).inSeconds;
      setState(() {
        _errorMessage = 'Too many failed attempts. Please try again in ${remainingTime}s.';
      });
      return;
    }

    // Check credentials
    if (username == 'admin' && password == 'admin123') {
      context.go('/admin');
    } else if (username == 'student01' && password == 'pass123') {
      context.go('/student-home');
    } else if (username == 'security01' && password == 'sec123') {
      context.go('/qr-scanner');
    } else {
      setState(() {
        _failedAttempts++;
        if (_failedAttempts >= 5) {
          _blockTime = DateTime.now().add(Duration(minutes: 5));
          _startTimer();
          _errorMessage = 'Too many failed attempts. Please try again in 300s.';
        } else {
          _errorMessage = 'Invalid username or password';
        }
      });
    }
  }

  // Starts a timer that updates the error message every second
  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_blockTime != null && DateTime.now().isBefore(_blockTime!)) {
        final remaining = _blockTime!.difference(DateTime.now()).inSeconds;
        setState(() {
          _errorMessage = 'Too many failed attempts. Please try again in ${remaining}s.';
        });
      } else {
        setState(() {
          _failedAttempts = 0;
          _blockTime = null;
          _errorMessage = '';
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer safely
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universal Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _failedAttempts >= 5 && _blockTime != null
                  ? null
                  : () => _handleLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
