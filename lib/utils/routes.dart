import 'package:go_router/go_router.dart';

// SCREEN IMPORTS
import '../screens/auth/login_screen.dart';
import '../screens/guest/guest_home.dart';
import '../screens/exhibitor/exhibitor_dashboard.dart';
import '../screens/exhibitor/application_flow_screen.dart';
import '../screens/exhibitor/my_applications.dart';
import '../screens/exhibitor/payment_screen.dart'; // <--- NEW IMPORT
import '../screens/organizer/organizer_dashboard.dart';
import '../screens/organizer/floorplan_upload.dart';
import '../screens/admin/admin_dashboard.dart'; // Make sure this file exists, or remove the route if not ready
import '../models/types.dart';


final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/guest',
      builder: (context, state) => const GuestScreen(),
    ),
    
    // --- EXHIBITOR ROUTES ---
    GoRoute(
      path: '/exhibitor',
      builder: (context, state) => const ExhibitorDashboard(),
      routes: [
        GoRoute(
          path: 'flow',
          builder: (context, state) => const ApplicationFlowScreen(),
        ),
        GoRoute(
          path: 'applications',
          builder: (context, state) => MyApplications(
            applications: [
              ApplicationRecord(id: '1', eventName: 'Tech Expo', boothType: 'Small', submissionDate: '2025-07-05', status: 'Pending'),
            ],
            onView: (app) {},
          ),
        ),
        // NEW PAYMENT ROUTE
        GoRoute(
          path: 'payment',
          builder: (context, state) => const PaymentScreen(),
        ),
      ],
    ),

    // --- ORGANIZER ROUTES ---
    GoRoute(
      path: '/organizer',
      builder: (context, state) => const OrganizerDashboard(),
      routes: [
        GoRoute(
          path: 'upload',
          builder: (context, state) => const FloorplanUploadScreen(),
        ),
      ],
    ),

    // --- ADMIN ROUTE ---
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(), // Ensure you created this file from previous steps
    ),
  ],
);