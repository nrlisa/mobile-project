import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart'; // ADDED: Import AuthService

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            // CHANGED: Added actual Firebase Logout logic
            onPressed: () {
              AuthService().logout(); 
              context.go('/'); // Goes to root (Login)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Admin Panel", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            _buildAdminButton(context, "User Management", Icons.people, '/admin/users'),
            const SizedBox(height: 16),
            _buildAdminButton(context, "Global Exhibition Management", Icons.public, '/admin/global-exhibitions'),
            const SizedBox(height: 16),
            _buildAdminButton(context, "Floor Plan Upload", Icons.map, '/admin/floorplan'),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context, String title, IconData icon, String route) {
    return ElevatedButton.icon(
      onPressed: () => context.push(route),
      icon: Icon(icon, size: 28),
      label: Text(title, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}