import 'package:flutter/material.dart';
import '../../../models/types.dart';

class EventSelection extends StatelessWidget {
  final Function(Event) onEventSelected;

  const EventSelection({super.key, required this.onEventSelected});

  // FIXED: Renamed to camelCase
  static final List<Event> events = [
    Event(id: '1', title: 'Global Tech Expo 2025', date: '1-3 August 2025', location: 'Quill City Mall', icon: 'globe'),
    Event(id: '2', title: 'Creative Art Expo 2025', date: '10-15 September 2025', location: 'KLCC Convention Hall', icon: 'pen'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search event',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // Event List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length, 
            // FIXED: Removed double underscore
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final event = events[index];
              return GestureDetector(
                onTap: () => onEventSelected(event),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
                        child: Icon(event.icon == 'globe' ? Icons.public : Icons.brush, color: Colors.black),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.1)),
                            const SizedBox(height: 4),
                            Text(event.date, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                            Text(event.location, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}