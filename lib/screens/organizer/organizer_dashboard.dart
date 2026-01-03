import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  final AuthService authService = AuthService();
  final DbService dbService = DbService();
  Stream<QuerySnapshot>? _appStream;

  @override
  void initState() {
    super.initState();
    if (authService.currentUser != null) {
      _appStream = dbService.getOrganizerApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF), // Light lavender/white
      appBar: AppBar(
        title: const Text(
          "Organizer Dashboard",
          style: TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF222222)),
            onPressed: () {
              authService.logout();
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
              "Welcome, Organizer",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222), // Dark Charcoal
              ),
            ),
            const SizedBox(height: 20),
            
            // --- SUMMARY WIDGETS ---
            if (_appStream != null)
            StreamBuilder<QuerySnapshot>(
              stream: _appStream!,
              builder: (context, appSnapshot) {
                // Calculate Stats
                int pendingApps = 0;
                double totalRevenue = 0;

                if (appSnapshot.hasData) {
                  final apps = appSnapshot.data!.docs;
                  pendingApps = apps.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == 'Pending';
                  }).length;

                  totalRevenue = apps.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['paymentStatus'] == 'Paid';
                  }).fold(0.0, (total, doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return total + (data['totalAmount'] ?? 0.0);
                  });
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildSummaryStat("Total Revenue", "RM ${totalRevenue.toStringAsFixed(0)}", Colors.green, Icons.attach_money)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSummaryStat("Pending Apps", "$pendingApps", Colors.orange, Icons.pending_actions)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }
            ),
            // -----------------------

            // 1. Manage Exhibitions
            _buildDashboardCard(
              context,
              title: "Manage Exhibitions",
              subtitle: "Create, edit, and schedule your upcoming events.",
              icon: Icons.calendar_today,
              iconColor: Colors.blue,
              bgColor: Colors.blue.withValues(alpha: 0.1),
              onTap: () => context.go('/organizer/exhibitions'),
            ),
            const SizedBox(height: 16),

            // 2. Booth List View
            _buildDashboardCard(
              context,
              title: "Booth List View",
              subtitle: "Monitor booth assignments and availability in real-time.",
              icon: Icons.grid_view,
              iconColor: Colors.orange,
              bgColor: Colors.orange.withValues(alpha: 0.1),
              onTap: () => context.go('/organizer/booths'),
            ),
            const SizedBox(height: 16),

            // 3. View Applications
            _buildDashboardCard(
              context,
              title: "View Applications",
              subtitle: "Review, approve, or reject pending exhibitor requests.",
              icon: Icons.assignment,
              iconColor: Colors.green,
              bgColor: Colors.green.withValues(alpha: 0.1),
              onTap: () => context.go('/organizer/applications'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Color(0xFF222222), fontSize: 18, fontWeight: FontWeight.bold)),
        ],
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