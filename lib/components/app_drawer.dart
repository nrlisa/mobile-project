import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart'; // Import AuthService

class AppDrawer extends StatelessWidget {
  final String role;

  const AppDrawer({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryBlue),
            accountName: Text(role, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text("$role@example.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppTheme.primaryBlue),
            ),
          ),

          // Menu Items
          if (role == 'Exhibitor') ...[
            _buildItem(context, Icons.add_circle_outline, "New Application", '/exhibitor/flow'),
            _buildItem(context, Icons.list_alt, "My Applications", '/exhibitor/applications'),
          ],

          if (role == 'Organizer') ...[
             _buildItem(context, Icons.dashboard, "Dashboard", '/organizer'),
             _buildItem(context, Icons.map, "Manage Floorplans", '/organizer/upload'),
             _buildItem(context, Icons.edit_calendar, "Manage Exhibitions", '/organizer/exhibitions'), // Fixed route based on your routes.dart
          ],

          const Spacer(),
          const Divider(),
          
          // Fixed Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorRed),
            title: const Text(
              "Logout", 
              style: TextStyle(
                color: AppTheme.errorRed, 
                fontWeight: FontWeight.bold
              )
            ),
            onTap: () async {
              // 1. Close the drawer first
              context.pop(); 
              
              // 2. Perform actual Firebase Logout
              await AuthService().logout();
              
              // 3. Navigate to Login
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper for standard navigation items only
  Widget _buildItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textGrey),
      title: Text(title, style: const TextStyle(color: AppTheme.textBlack)),
      onTap: () {
        context.pop(); // Close drawer
        context.go(route);
      },
    );
  }
}