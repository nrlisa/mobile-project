import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart'; 
import '../../services/db_service.dart';
import '../../models/event_model.dart';
import '../../services/auth_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  bool _isPublish = false;
  bool _isSaving = false;

  // Function to select dates (Wireframe Page 7: Start/End Date)
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) _endDate = _startDate;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // PHASE 2: Logic to insert new events into the database
  Future<void> _saveExhibition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Ensure we have the current Organizer ID
      final String organizerId = AuthService().currentUser?.uid ?? "unknown";
      
      // Creating the Event Container
      final newEvent = EventModel(
        id: const Uuid().v4(), // Column: EventID
        name: _nameController.text.trim(), // Column: Name
        // Column: Date (Formated as Range per Page 21) [cite: 278]
        date: "${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}",
        location: _locationController.text.trim(), // Column: Location
        description: _descController.text.trim(),
        isPublished: _isPublish, // Controls visibility on Guest Page
        organizerId: organizerId,
      );

      // Save to Firebase using the fixed DbService
      await DbService().addEvent(newEvent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Exhibition Saved to Firebase!")),
        );
        context.pop(); // Returns to Manage Exhibitions (Page 6)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error saving: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Exhibition"), // Page 7 Title [cite: 47]
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wireframe Page 7: Exhibition Name Input [cite: 52]
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Exhibition Name"),
                validator: (v) => v!.isEmpty ? "Enter a name" : null,
              ),
              const SizedBox(height: 20),
              
              // Wireframe Page 7: Location Input [cite: 56]
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location"),
                validator: (v) => v!.isEmpty ? "Enter a location" : null,
              ),
              const SizedBox(height: 20),

              // Wireframe Page 7: Date Selection [cite: 54, 55]
              ListTile(
                title: const Text("Start Date"),
                subtitle: Text("${_startDate.day}/${_startDate.month}/${_startDate.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: const Text("End Date"),
                subtitle: Text("${_endDate.day}/${_endDate.month}/${_endDate.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              
              // Wireframe Page 6: Publish Toggle [cite: 44]
              SwitchListTile(
                title: const Text("Publish Now?"),
                subtitle: const Text("If OFF, guests cannot see this event."),
                value: _isPublish,
                onChanged: (val) => setState(() => _isPublish = val),
              ),

              const SizedBox(height: 40),
              
              _isSaving
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => context.pop(),
                          child: const Text("Cancel"), // Page 7 Cancel [cite: 58]
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveExhibition, 
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text("Save", style: TextStyle(color: Colors.white)), // Page 7 Save [cite: 59]
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}