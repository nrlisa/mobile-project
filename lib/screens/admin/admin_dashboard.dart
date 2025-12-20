import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

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

            // 1. User Management (Standard Link)
            _buildAdminButton(
              context: context, 
              title: "User Management", 
              icon: Icons.people, 
              onTap: () => context.push('/admin/users')
            ),
            
            const SizedBox(height: 16),

            // 2. Global Exhibition Management (Standard Link)
            _buildAdminButton(
              context: context, 
              title: "Global Exhibition Management", 
              icon: Icons.public, 
              onTap: () => context.push('/admin/global-exhibitions')
            ),

            const SizedBox(height: 16),

            // --- FIX IS HERE ---
            // 3. Floor Plan Upload (PASSING DATA)
            // We pass a 'Demo Event' so the next screen knows what to load.
            _buildAdminButton(
              context: context,
              title: "Floor Plan Upload (Demo)",
              icon: Icons.map,
              onTap: () {
                // We use 'extra' to pass the required ID and Name
                context.push(
                  '/admin/floorplan', 
                  extra: {
                    'eventId': 'demo_event_123', 
                    'eventName': 'Demo Exhibition'
                  }
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton({
    required BuildContext context, 
    required String title, 
    required IconData icon, 
    required VoidCallback onTap
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
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