import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF), // Light lavender/white
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF222222)),
            onPressed: () {
              AuthService().logout();
              context.go('/guest');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "System Administration",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222), // Dark Charcoal
              ),
            ),
            const SizedBox(height: 20),
            
            // 1. User Management
            _buildDashboardCard(
              context,
              title: "User Management",
              subtitle: "Manage registered users and roles.",
              icon: Icons.people_alt,
              iconColor: Colors.orange,
              bgColor: Colors.orange.withValues(alpha: 0.1),
              onTap: () => context.go('/admin/users'),
            ),
            const SizedBox(height: 16),

            // 2. Global Exhibitions
            _buildDashboardCard(
              context,
              title: "Global Exhibitions",
              subtitle: "View all exhibitions across the system.",
              icon: Icons.public,
              iconColor: Colors.blue,
              bgColor: Colors.blue.withValues(alpha: 0.1),
              onTap: () => context.go('/admin/global-exhibitions'),
            ),
            const SizedBox(height: 16),

            // 3. Floorplan Settings
            _buildDashboardCard(
              context,
              title: "Floorplan Settings",
              subtitle: "Configure default floorplan layouts.",
              icon: Icons.map,
              iconColor: Colors.purple,
              bgColor: Colors.purple.withValues(alpha: 0.1),
              onTap: () => context.go('/admin/floorplan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777), // Slate Gray
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chevron
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}