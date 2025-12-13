// Make sure this line exists and is correct:
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrganizerDashboard extends StatelessWidget {
  const OrganizerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Organizer Dashboard"),
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
            const Text(
              "Welcome, Organizer!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            
            // Manage Exhibitions Button
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to manage exhibitions (future feature)
              },
              icon: const Icon(Icons.event),
              label: const Text("Manage Exhibitions"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            
            const SizedBox(height: 20),

            // UPLOAD FLOORPLAN BUTTON (Required for your demo)
            ElevatedButton.icon(
              onPressed: () => context.push('/organizer/upload'),
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text("Upload Floorplan", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}