import 'package:flutter/material.dart';
import '../../../models/event_model.dart';
import '../../../services/db_service.dart';

class EventSelection extends StatefulWidget {
  final Function(EventModel) onEventSelected;

  const EventSelection({super.key, required this.onEventSelected});

  @override
  State<EventSelection> createState() => _EventSelectionState();
}

class _EventSelectionState extends State<EventSelection> {
  final DbService _dbService = DbService();
  late Future<List<Map<String, dynamic>>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _dbService.getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No exhibitions available."));
        }

        final rawData = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rawData.length,
          itemBuilder: (context, index) {
            final data = rawData[index];
            final event = EventModel.fromJson(data); 

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.business, color: Colors.blue),
                title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${event.location}\n${event.date.isNotEmpty ? event.date : 'Date TBD'}"),
                onTap: () => widget.onEventSelected(event),
              ),
            );
          },
        );
      },
    );
  }
}