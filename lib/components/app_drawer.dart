import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_theme.dart'; 

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
             _buildItem(context, Icons.edit_calendar, "Manage Exhibitions", '/organizer'), 
          ],

          const Spacer(),
          const Divider(),
          _buildItem(context, Icons.logout, "Logout", '/login', isDestructive: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String title, String route, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppTheme.errorRed : AppTheme.textGrey),
      title: Text(
        title, 
        style: TextStyle(
          color: isDestructive ? AppTheme.errorRed : AppTheme.textBlack,
          fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal
        )
      ),
      onTap: () {
        context.pop(); // Close drawer
        context.go(route);
      },
    );
  }
}