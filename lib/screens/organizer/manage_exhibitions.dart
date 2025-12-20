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
  
  // State for functional date pickers
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Add Exhibition" : "Manage Exhibitions"),
        centerTitle: true,
      ),
      body: _isEditing ? _buildForm() : _buildList(),
    );
  }

  // --- PAGE 6: LIST VIEW ---
  // Shows all exhibitions created by the current Organizer
  Widget _buildList() {
    final String currentUserId = _authService.currentUser?.uid ?? "";
    return StreamBuilder<List<EventModel>>(
      stream: _dbService.getOrganizerEvents(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snapshot.data ?? [];
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...events.map((event) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${event.location}\n${event.date}"),
                trailing: SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // PUBLISH SLIDER: Controls visibility for Exhibitors/Guests
                      Switch(
                        value: event.isPublished,
                        activeThumbColor: Colors.green,
                        onChanged: (val) async {
                          setState(() {
                            event.isPublished = val;
                          });
                          await _dbService.addEvent(event); 
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _nameController.clear();
                _locationController.clear();
                _descController.clear();
                setState(() => _isEditing = true);
              },
              child: const Text("Add New Exhibition"),
            ),
          ],
        );
      },
    );
  }

  // --- PAGE 7: ADD FORM ---
  // Step 1 of the exhibition setup process
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepper(1), // Step 1 Active
          const SizedBox(height: 30),
          
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Exhibition Name", border: OutlineInputBorder())),
          const SizedBox(height: 16),

          // FUNCTIONAL DATE PICKERS
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text("Start Date", style: TextStyle(fontSize: 12)),
                  subtitle: Text("${_startDate.day}/${_startDate.month}/${_startDate.year}"),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _startDate = picked);
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text("End Date", style: TextStyle(fontSize: 12)),
                  subtitle: Text("${_endDate.day}/${_endDate.month}/${_endDate.year}"),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _startDate,
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _endDate = picked);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          TextField(controller: _locationController, decoration: const InputDecoration(labelText: "Location", border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()), maxLines: 3),
          const SizedBox(height: 30),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    
                    // 1. GENERATE ID: Ensures a non-empty document path
                    final String eventId = const Uuid().v4(); 
                    
                    final newEvent = EventModel(
                      id: eventId,
                      name: _nameController.text,
                      date: "${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}",
                      location: _locationController.text,
                      description: _descController.text,
                      isPublished: false,
                      organizerId: _authService.currentUser?.uid ?? "",
                    );

                    // 2. SAVE TO DATABASE
                    await _dbService.addEvent(newEvent);
                    
                    if (!mounted) return;
                    messenger.showSnackBar(const SnackBar(content: Text("Event Saved. Moving to Booths...")));

                    // 3. TRANSITION TO PHASE 3: Pass the specific ID
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => ManageBoothsScreen(eventId: eventId))
                    );
                    
                    setState(() => _isEditing = false);
                  },
                  child: const Text("Next"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- STEPPER COMPONENT ---
  // Simplified to 2 steps: Exhibition Setup and Booth Management
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

  Widget _circleStep(String label, bool active) => Column(
    children: [
      CircleAvatar(
        radius: 14, 
        backgroundColor: active ? Colors.blue : Colors.blue.shade100,
        child: active && label == "Add/Edit" && !_isEditing ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal))
    ]
  );

  Widget _line(bool active) => Container(
    width: 60, 
    height: 2, 
    margin: const EdgeInsets.only(bottom: 15),
    color: active ? Colors.blue : Colors.grey.shade300
  );
}