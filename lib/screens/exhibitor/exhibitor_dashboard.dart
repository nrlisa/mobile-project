import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class ExhibitorDashboard extends StatelessWidget {
  const ExhibitorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF), // Light lavender/white
      appBar: AppBar(
        title: const Text(
          "Exhibitor Dashboard",
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
              "Welcome, Exhibitor",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222), // Dark Charcoal
              ),
            ),
            const SizedBox(height: 20),
            
            // Card for Booking Booths
            _buildDashboardCard(
              context,
              title: "Book Booths",
              subtitle: "Explore available venues and secure your vendor space.",
              icon: Icons.storefront,
              iconColor: const Color(0xFF2E5BFF), // Deeper blue
              bgColor: const Color(0xFF2E5BFF).withValues(alpha: 0.1),
              // Navigates to the flow where exhibitors pick an event
              onTap: () => context.push('/exhibitor/events'), 
            ),
            
            const SizedBox(height: 16),
            
            // Card for My Applications
            _buildDashboardCard(
              context,
              title: "My Applications",
              subtitle: "Track the status and history of your exhibition requests.",
              icon: Icons.local_activity,
              iconColor: Colors.green,
              bgColor: Colors.green.withValues(alpha: 0.1),
              // Navigates to the exhibitor's application history
              onTap: () => context.push('/exhibitor/my-applications'),
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