import 'package:flutter/material.dart';
import '../../services/db_service.dart';
import 'admin_floorplan.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalExhibitionsScreen extends StatefulWidget {
  const GlobalExhibitionsScreen({super.key});

  @override
  State<GlobalExhibitionsScreen> createState() => _GlobalExhibitionsScreenState();
}

class _GlobalExhibitionsScreenState extends State<GlobalExhibitionsScreen> {
  final DbService _dbService = DbService();

  // Function to refresh UI after deletion or update
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Global Exhibitions")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEventDialog(context),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbService.getEvents(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(child: Text("No exhibitions found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final String eventId = event['id'] ?? "";
              final String eventName = event['name'] ?? "Unnamed Exhibition";
              final String location = event['location'] ?? "No Location";
              final bool isPublished = event['isPublished'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("$location\nStatus: ${isPublished ? 'Published' : 'Draft'}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // EDIT BUTTON: Metadata
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit Details',
                        onPressed: () => _showEditEventDialog(context, eventId, event),
                      ),
                      // MAP BUTTON: Floorplan
                      IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        tooltip: 'Edit Floorplan',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminFloorplanScreen(
                              eventId: eventId,
                              eventName: eventName,
                            ),
                          ),
                        ),
                      ),
                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Exhibition',
                        onPressed: () => _confirmDelete(context, eventId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Dialog to Create New Event
  void _showCreateEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    DateTimeRange? selectedDateRange;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Exhibition"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Event Name")),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  selectedDateRange = picked;
                }
              },
              child: const Text("Select Dates"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && selectedDateRange != null) {
                await _dbService.createEvent(
                  name: nameController.text,
                  location: locationController.text,
                  startDate: selectedDateRange!.start,
                  endDate: selectedDateRange!.end,
                  floorPlanUrl: '',
                  organizerId: FirebaseAuth.instance.currentUser?.uid ?? 'admin',
                );
                if (context.mounted) Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  // Dialog to edit Exhibition Name and Status
  void _showEditEventDialog(BuildContext context, String id, Map data) {
    final nameController = TextEditingController(text: data['name']);
    bool publishedStatus = data['isPublished'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Exhibition"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Exhibition Name"),
              ),
              SwitchListTile(
                title: const Text("Published"),
                value: publishedStatus,
                onChanged: (val) => setDialogState(() => publishedStatus = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await _dbService.updateEvent(id, {
                  'name': nameController.text,
                  'isPublished': publishedStatus,
                });
                if (context.mounted) Navigator.pop(context);
                _refresh(); // UI update
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // Confirmation before permanent deletion
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Exhibition?"),
        content: const Text("This will permanently remove this event record."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _dbService.deleteEvent(id);
              if (context.mounted) Navigator.pop(context);
              _refresh(); // UI update
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}