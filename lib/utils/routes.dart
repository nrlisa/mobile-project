import 'package:go_router/go_router.dart';
import 'package:project3_lab04_nurlisa_52215124595/screens/guest/guest_home.dart';

// AUTH & GUEST IMPORTS
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/guest/event_details.dart';

// EXHIBITOR IMPORTS
import '../screens/exhibitor/exhibitor_dashboard.dart';
import '../screens/exhibitor/application_flow_screen.dart';
import '../screens/exhibitor/my_applications.dart';

// ORGANIZER IMPORTS
import '../screens/organizer/organizer_dashboard.dart';
import '../screens/organizer/manage_exhibitions.dart'; 
import '../screens/organizer/manage_booths.dart';      
import '../screens/organizer/organizer_applications.dart'; 
import '../screens/organizer/floorplan_upload.dart';   
import '../screens/organizer/add_event_screen.dart'; // Added: Needed for Page 7

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
      // FIX: Ensure this matches the class name in guest_home.dart (GuestHomeScreen)
      builder: (context, state) => const GuestHomeScreen(), 
    ),
    GoRoute(
      path: '/guest/details',
      builder: (context, state) => const EventDetailsScreen(eventId: '',),
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
        GoRoute(
          path: 'exhibitions',
          builder: (context, state) => const ManageExhibitionsScreen(),
        ),
        GoRoute(
          path: 'booths',
          builder: (context, state) => const ManageBoothsScreen(eventId: '',),
        ),
        GoRoute(
          path: 'applications',
          builder: (context, state) => const OrganizerApplicationsScreen(),
        ),
        GoRoute(
          path: 'upload',
          builder: (context, state) => const FloorplanUploadScreen(),
        ),
        // ADDED: Route for your Page 7 Create Exhibition
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
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: 'global-exhibitions',
          builder: (context, state) => const GlobalExhibitionsScreen(),
        ),
        // FIX: Added data handling for the Floorplan Editor
        GoRoute(
          path: 'floorplan',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>? ?? 
                {'eventId': 'default_event', 'eventName': 'Exhibition'};
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

class GuestHome {
  const GuestHome();
}