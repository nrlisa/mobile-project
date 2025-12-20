import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/db_service.dart';
import '../../models/event_model.dart';
// Ensure this exists for styling

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcoming Events"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // FIXED: Login button instead of logout for guests
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, Guest!",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Or AppTheme.primaryDark if defined
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Explore upcoming exhibitions below.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              "Available Exhibitions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // 2. The Dynamic List (StreamBuilder)
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: DbService().getGuestEvents(), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        const Text("No upcoming exhibitions found.",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final events = snapshot.data!;
                return ListView.builder(
                  itemCount: events.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _buildEventCard(context, event);
                  },
                );
              },
            ),
          ),
          
          // Optional: "Next" button from your design if needed
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/guest/details'),
                child: const Text("View General Details"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build the card UI with your opacity design
  Widget _buildEventCard(BuildContext context, EventModel event) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(
            '/floorplan-viewer', 
            extra: {
              'eventId': event.id,
              'eventName': event.name
            }
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            // Uses the light blue background from your design
            color: Colors.blue.shade50.withValues(alpha:.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.event, size: 40, color: Colors.blueAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${event.date} • ${event.location}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}