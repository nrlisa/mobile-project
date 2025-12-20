import 'package:flutter/material.dart';
import '../../services/db_service.dart';
import '../../services/auth_service.dart';
import '../../models/event_model.dart';
import 'package:uuid/uuid.dart';
import 'manage_booths.dart';

class ManageExhibitionsScreen extends StatefulWidget {
  const ManageExhibitionsScreen({super.key});

  @override
  State<ManageExhibitionsScreen> createState() => _ManageExhibitionsScreenState();
}

class _ManageExhibitionsScreenState extends State<ManageExhibitionsScreen> {
  bool _isEditing = false;
  final _dbService = DbService();
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  
  // Removed final to allow updates from Date Pickers if you implement them
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Add Exhibition" : "Manage Exhibitions"),
      ),
      body: _isEditing ? _buildForm() : _buildList(),
    );
  }

  Widget _buildList() {
    final String currentUserId = _authService.currentUser?.uid ?? "";
    return StreamBuilder<List<EventModel>>(
      stream: _dbService.getOrganizerEvents(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final events = snapshot.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...events.map((event) => Card(
              child: ListTile(
                title: Text(event.name),
                subtitle: Text("${event.location}\n${event.date}"),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      // ADDED: The Publish Slide Box (Switch)
                      Switch(
                        value: event.isPublished,
                        onChanged: (val) {
                          setState(() {
                            event.isPublished = val;
                          });
                          _dbService.addEvent(event); // Updates status in DB
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await _dbService.deleteEvent(event.id);
                          if (!mounted) return;
                          messenger.showSnackBar(const SnackBar(content: Text("Exhibition Deleted")));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )),
            ElevatedButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text("Add New Exhibition"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Updated to show step 1 as active
          _buildStepper(1), 
          const SizedBox(height: 20),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Exhibition Name")),
          const SizedBox(height: 16),
          TextField(controller: _locationController, decoration: const InputDecoration(labelText: "Location")),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final String eventId = const Uuid().v4(); 
              
              final newEvent = EventModel(
                id: eventId,
                name: _nameController.text,
                date: "${_startDate.day}/${_startDate.month} - ${_endDate.day}/${_endDate.month}/${_endDate.year}",
                location: _locationController.text,
                description: _descController.text,
                isPublished: false,
                organizerId: _authService.currentUser?.uid ?? "",
              );

              await _dbService.addEvent(newEvent);
              
              if (!mounted) return;
              messenger.showSnackBar(const SnackBar(content: Text("Event Saved. Define Booths Next.")));

              // Passing eventId ensures booths are linked ONLY to this event
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => ManageBoothsScreen(eventId: eventId))
              );
              
              setState(() => _isEditing = false);
            },
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  // Simplified Stepper to 2 steps as requested
  Widget _buildStepper(int step) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleStep("Add/Edit", step >= 1),
        _line(step >= 2),
        _circleStep("Manage Booth", step >= 2),
      ],
    );
  }

  Widget _circleStep(String label, bool active) => Column(children: [
    CircleAvatar(radius: 12, backgroundColor: active ? Colors.blue : Colors.blue.shade100),
    Text(label, style: const TextStyle(fontSize: 10))
  ]);

  Widget _line(bool active) => Container(width: 40, height: 2, color: active ? Colors.blue : Colors.grey.shade300);
}