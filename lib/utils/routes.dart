import 'package:go_router/go_router.dart';

// AUTH & GUEST IMPORTS
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/guest/guest_home.dart';
import '../screens/guest/event_details.dart';

// EXHIBITOR IMPORTS
import '../screens/exhibitor/exhibitor_dashboard.dart';
import '../screens/exhibitor/application_flow_screen.dart';
import '../screens/exhibitor/my_applications.dart';

// ORGANIZER IMPORTS
import '../screens/organizer/organizer_dashboard.dart';
import '../screens/organizer/manage_exhibitions.dart'; // Ensure you created this file
import '../screens/organizer/manage_booths.dart';      // Ensure you created this file
import '../screens/organizer/organizer_applications.dart'; // Ensure you created this file
import '../screens/organizer/floorplan_upload.dart';   // Ensure you created this file

// ADMIN IMPORTS
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/user_management.dart';
import '../screens/admin/global_exhibitions.dart';
import '../screens/admin/admin_floorplan.dart';

final GoRouter router = GoRouter(
  initialLocation: '/guest', // Start app as Guest
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
      builder: (context, state) => const GuestScreen(),
    ),
    GoRoute(
      path: '/guest/details',
      builder: (context, state) => const EventDetailsScreen(),
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
        // THESE WERE MISSING OR INCORRECT:
        GoRoute(
          path: 'exhibitions',
          builder: (context, state) => const ManageExhibitionsScreen(),
        ),
        GoRoute(
          path: 'booths',
          builder: (context, state) => const ManageBoothsScreen(),
        ),
        GoRoute(
          path: 'applications',
          builder: (context, state) => const OrganizerApplicationsScreen(),
        ),
        GoRoute(
          path: 'upload',
          builder: (context, state) => const FloorplanUploadScreen(),
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
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: 'global-exhibitions',
          builder: (context, state) => const GlobalExhibitionsScreen(),
        ),
        GoRoute(
          path: 'floorplan',
          builder: (context, state) => const AdminFloorplanScreen(),
        ),
      ],
    ),
  ],
);