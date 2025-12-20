import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class OrganizerDashboard extends StatelessWidget {
  const OrganizerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APPBAR: Styled per Page 5 ---
      appBar: AppBar(
        title: const Text(
          "Organizer (Dashboard)",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              AuthService().logout();
              context.go('/login');
            },
          ),
        ],
      ),

      // --- DRAWER: Standard side menu ---
      drawer: const Drawer(
        child: Center(child: Text("Organizer Menu")),
      ),

      // --- BODY: Implementing Phase 2 & 3 Buttons ---
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PHASE 2: THE CONTAINER (EVENTS)
              // This button leads to Page 6: Manage Exhibitions [cite: 32, 36]
              _buildDashboardButton(
                context, 
                "Manage Exhibitions", 
                '/organizer/exhibitions',
                Icons.event,
              ),
              const SizedBox(height: 40),
              
              // PHASE 3: THE INVENTORY (BOOTHS)
              // This button leads to Page 8: Manage Booths [cite: 33, 61]
              _buildDashboardButton(
                context, 
                "Manage Booth Types\n/ Prices", 
                '/organizer/booths',
                Icons.storefront,
              ),
              const SizedBox(height: 40),
              
              // VIEW APPLICATIONS
              // This button leads to Page 10: Applications [cite: 34, 85]
              _buildDashboardButton(
                context, 
                "View\nApplications", 
                '/organizer/applications',
                Icons.assignment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- RECTANGULAR BUTTON WIDGET: Matching Wireframe Style ---
  Widget _buildDashboardButton(BuildContext context, String title, String route, IconData icon) {
    return SizedBox(
      width: double.infinity, 
      height: 130, // Large rectangular shape from wireframe
      child: ElevatedButton(
        onPressed: () => context.push(route),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300, // Grey color from wireframe [cite: 32, 33]
          foregroundColor: Colors.black,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30), // Added icon for clarity
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}