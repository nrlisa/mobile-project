import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project3_lab04_nurlisa_52215124595/screens/organizer/booth_list_view';
import '../../services/auth_service.dart';
// FIXED: Using a relative import with the correct .dart extension [Inference]

class OrganizerDashboard extends StatelessWidget {
  const OrganizerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () async {
              await AuthService().logout(); // Standard logout flow
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),

      drawer: const Drawer(
        child: Center(child: Text("Organizer Menu")),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. MANAGE EXHIBITIONS
              _buildDashboardButton(
                context, 
                "Manage Exhibitions", 
                onTap: () => context.push('/organizer/exhibitions'),
                icon: Icons.event,
              ),
              const SizedBox(height: 20),
              
              // 2. BOOTH LIST VIEW
              // FIXED: Uses the unique class name OrganizerBoothListView [Inference]
              _buildDashboardButton(
                context, 
                "Booth List View", 
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrganizerBoothListView(),
                    ),
                  );
                },
                icon: Icons.list_alt,
              ),
              const SizedBox(height: 20),
              
              // 3. VIEW APPLICATIONS
              _buildDashboardButton(
                context, 
                "View\nApplications", 
                onTap: () => context.push('/organizer/applications'),
                icon: Icons.assignment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title, {required VoidCallback onTap, required IconData icon}) {
    return SizedBox(
      width: double.infinity, 
      height: 130, 
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300, 
          foregroundColor: Colors.black,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black54), 
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