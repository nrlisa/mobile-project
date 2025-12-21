import 'package:flutter/material.dart';
import '../../../models/types.dart';
import '../../../services/db_service.dart';

class EventSelection extends StatelessWidget {
  final Function(Event) onEventSelected;
  final DbService _dbService = DbService();

  EventSelection({super.key, required this.onEventSelected});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dbService.getEvents(), //
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No exhibitions."));

        final rawData = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rawData.length,
          itemBuilder: (context, index) {
            final data = rawData[index];
            
            // Updated to use named parameters as defined in types.dart
            final event = Event(
              id: data['id'] ?? '',
              name: data['name'] ?? 'Unnamed Exhibition',
              date: data['date']?.toString() ?? '',
              location: data['location'] ?? '',
              icon: data['icon'] ?? 'business',
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.business, color: Colors.blue),
                title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${event.location}\n${event.date}"),
                onTap: () => onEventSelected(event),
              ),
            );
          },
        );
      },
    );
  }
}