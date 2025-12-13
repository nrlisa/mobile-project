import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../components/app_drawer.dart';

class ExhibitorDashboard extends StatelessWidget {
  const ExhibitorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exhibitor Dashboard")),
      drawer: const AppDrawer(role: 'Exhibitor'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.primaryDark]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text("Welcome, Exhibitor!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                   SizedBox(height: 8),
                   Text("Manage your applications and booths from here.", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Quick Actions Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    context, 
                    "New Application", 
                    Icons.add_business, 
                    Colors.blue.shade50, 
                    AppTheme.primaryBlue,
                    () => context.go('/exhibitor/flow'),
                  ),
                  _buildActionCard(
                    context, 
                    "My Applications", 
                    Icons.folder_shared, 
                    Colors.orange.shade50, 
                    Colors.orange,
                    () => context.go('/exhibitor/applications'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color bg, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          // FIXED: Used withValues(alpha: ...)
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: bg,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}