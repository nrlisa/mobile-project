import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project3_lab04_nurlisa_52215124595/screens/exhibitor/exhibitor_flow_screen.dart';

// AUTH & GUEST IMPORTS
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/guest/guest_home.dart';
import '../screens/guest/guest_floorplan_viewer.dart'; 

// EXHIBITOR IMPORTS
import '../screens/exhibitor/exhibitor_dashboard.dart';
// <--- Check this file specifically
import '../screens/exhibitor/my_applications.dart';
import '../screens/exhibitor/steps/event_selection.dart';

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
import '../screens/admin/admin_reservations.dart';

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
        final extra = state.extra as Map<String, dynamic>?;
        final eventName = extra?['eventName'] as String? ?? "Event Details";
        return GuestFloorplanViewer(
          eventId: id,
          eventName: eventName,
        );
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
          path: 'events',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text("Select Event")),
            body: EventSelection(
              onEventSelected: (event) => context.push('/exhibitor/flow', extra: {'eventId': event.id}),
            ),
          ),
        ),
        GoRoute(
          path: '/flow',
          // Ensure this line uses the EXACT class name defined in application_flow_screen.dart
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final eventId = extra?['eventId'] as String?;
            return ApplicationFlowScreen(eventId: eventId);
          },
        ),
        GoRoute(
          path: 'my-applications',
          builder: (context, state) => MyApplications(
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
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final eventId = args?['eventId'] as String? ?? '';
            return ManageBoothsScreen(eventId: eventId);
          },
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
        GoRoute(
          path: 'reservations',
          builder: (context, state) => AdminReservationsScreen(),
        ),
      ],
    ),
  ],
);