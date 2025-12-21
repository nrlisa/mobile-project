import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// AUTH & GUEST IMPORTS
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/guest/guest_home.dart';
import '../screens/guest/event_details.dart';
import '../screens/guest/guest_floorplan_viewer.dart'; 

// EXHIBITOR IMPORTS
import '../screens/exhibitor/exhibitor_dashboard.dart';
import '../screens/exhibitor/application_flow_screen.dart'; // <--- Check this file specifically
import '../screens/exhibitor/my_applications.dart';

// ORGANIZER IMPORTS
import '../screens/organizer/organizer_dashboard.dart';
import '../screens/organizer/manage_exhibitions.dart'; 
import '../screens/organizer/manage_booths.dart';      
import '../screens/organizer/organizer_applications.dart'; 
import '../screens/organizer/floorplan_upload.dart';   
import '../screens/organizer/add_event_screen.dart'; 

// ADMIN IMPORTS
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/user_management.dart';
import '../screens/admin/global_exhibitions.dart';
import '../screens/admin/admin_floorplan.dart';

final GoRouter router = GoRouter(
  initialLocation: '/guest', 
  
  redirect: (context, state) {
    if (state.uri.toString() == '/') {
      return '/guest'; 
    }
    return null;
  },

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text("Route not found: ${state.uri}\nTry using a leading slash (/) in your navigation."),
    ),
  ),

  routes: [
    // --- AUTH & GUEST ---
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/guest',
      builder: (context, state) => const GuestHomeScreen(), 
    ),
    GoRoute(
      path: '/guest/details/:eventId',
      builder: (context, state) {
        final id = state.pathParameters['eventId'] ?? '';
        return EventDetailsScreen(eventId: id);
      },
    ),

    GoRoute(
      path: '/floorplan-viewer',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? 
            {'eventId': 'default', 'eventName': 'Exhibition'};
        return GuestFloorplanViewer( 
          eventId: args['eventId'],
          eventName: args['eventName'],
        );
      },
    ),

    // --- EXHIBITOR ROUTES ---
    GoRoute(
      path: '/exhibitor',
      builder: (context, state) => const ExhibitorDashboard(),
      routes: [
        GoRoute(
          path: 'flow',
          // Ensure this line uses the EXACT class name defined in application_flow_screen.dart
          builder: (context, state) => const ApplicationFlowScreen(),
        ),
        GoRoute(
          path: 'applications',
          builder: (context, state) => MyApplications(
            applications: const [],
            onView: (application) {},
          ),
        ),
      ],
    ),

    // --- ORGANIZER ROUTES ---
    GoRoute(
      path: '/organizer',
      builder: (context, state) => const OrganizerDashboard(),
      routes: [
        GoRoute(
          path: 'exhibitions',
          builder: (context, state) => const ManageExhibitionsScreen(),
        ),
        GoRoute(
          path: 'booths',
          builder: (context, state) => const ManageBoothsScreen(eventId: ''),
        ),
        GoRoute(
          path: 'applications',
          builder: (context, state) => const OrganizerApplicationsScreen(),
        ),
        GoRoute(
          path: 'upload',
          builder: (context, state) => const FloorplanUploadScreen(),
        ),
        GoRoute(
          path: 'add-event',
          builder: (context, state) => const AddEventScreen(),
        ),
      ],
    ),

    // --- ADMIN ROUTES ---
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
      routes: [
        GoRoute(
          path: 'users',
          builder: (context, state) => UserManagementScreen(),
        ),
        GoRoute(
          path: 'global-exhibitions',
          builder: (context, state) => const GlobalExhibitionsScreen(),
        ),
        GoRoute(
          path: 'floorplan',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>? ?? 
                {'eventId': 'default', 'eventName': 'Exhibition'};
            return AdminFloorplanScreen(
              eventId: args['eventId'],
              eventName: args['eventName'],
            );
          },
        ),
      ],
    ),
  ],
);