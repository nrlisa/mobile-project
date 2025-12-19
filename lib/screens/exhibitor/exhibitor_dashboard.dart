import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';

class ExhibitorDashboard extends StatefulWidget {
  const ExhibitorDashboard({super.key});

  @override
  State<ExhibitorDashboard> createState() => _ExhibitorDashboardState();
}

class _ExhibitorDashboardState extends State<ExhibitorDashboard> {
  final DbService _dbService = DbService();
  late Future<List<Map<String, dynamic>>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    // This now calls the correct Firestore method
    _eventsFuture = _dbService.getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exhibitor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().logout();
              context.go('/');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No upcoming events."));
          }

          var events = snapshot.data!;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.event_available, color: Colors.blue, size: 40),
                  title: Text(event['name'] ?? 'Unnamed Event', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${event['location'] ?? 'No Location'} \nBooths available!"),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Pass ID as String to keep routes simple
                    context.push('/guest/details', extra: {'eventId': event['id'], 'eventName': event['name']});
                    // Note: I updated the path to match your routes.dart '/guest/details' 
                    // or define a specific exhibitor details route if you prefer.
                    // If you want to use the route from your routes.dart file:
                    // context.push('/guest/details', extra: ...); 
                    // Just ensure your GoRouter setup expects 'extra' correctly, 
                    // or passes it via path parameters like '/event/${event['id']}'
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}