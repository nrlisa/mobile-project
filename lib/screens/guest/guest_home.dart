import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/db_service.dart';
import '../../models/event_model.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final DbService dbService = DbService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF), // Light lavender/white
      appBar: AppBar(
        title: const Text(
          "Guest Portal",
          style: TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/login'),
            icon: const Icon(Icons.login, color: Color(0xFF2E5BFF)),
            label: const Text("Login", style: TextStyle(color: Color(0xFF2E5BFF), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          TextButton(
             onPressed: () => context.push('/register'),
             child: const Text("Register", style: TextStyle(color: Color(0xFF222222))),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome, Guest",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222), // Dark Charcoal
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search exhibitions...",
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Upcoming Exhibitions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: dbService.getGuestEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No public events found.", style: TextStyle(color: Color(0xFF777777))));
                }

                final events = snapshot.data!.where((event) {
                  return event.name.toLowerCase().contains(_searchQuery) ||
                         event.location.toLowerCase().contains(_searchQuery);
                }).toList();

                if (events.isEmpty) {
                   return const Center(child: Text("No matching events found.", style: TextStyle(color: Color(0xFF777777))));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _buildEventCard(context, event);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.push('/guest/details/${event.id}'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event_available, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 16),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${event.date} • ${event.location}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777), // Slate Gray
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chevron
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}