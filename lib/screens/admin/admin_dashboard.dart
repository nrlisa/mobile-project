import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.red[800], // Distinct color for Admin
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.red[800]),
            const SizedBox(height: 20),
            const Text(
              "Administrator Access", 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            const Text("Manage users, approvals, and system logs."),
            const SizedBox(height: 30),
            
            // Mock Admin Action Button
            ElevatedButton.icon(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("System Scan Started..."))
                );
              },
              icon: const Icon(Icons.security),
              label: const Text("Run Security Audit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}