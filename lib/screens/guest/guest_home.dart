import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// IMPORTANT: Class name must match what is used in routes.dart
class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcoming Events"),
        actions: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Text("Welcome Guest!", style: TextStyle(fontSize: 24)),
             const SizedBox(height: 20),
             ElevatedButton(
               onPressed: () => context.go('/login'), 
               child: const Text("Go to Login")
             ),
          ],
        ),
      ),
    );
  }
}