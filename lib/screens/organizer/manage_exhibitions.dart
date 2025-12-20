import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/db_service.dart';
import '../../services/auth_service.dart';
import '../../models/event_model.dart';
import 'package:uuid/uuid.dart';

class ManageExhibitionsScreen extends StatefulWidget {
  const ManageExhibitionsScreen({super.key});

  @override
  State<ManageExhibitionsScreen> createState() => _ManageExhibitionsScreenState();
}

class _ManageExhibitionsScreenState extends State<ManageExhibitionsScreen> {
  final _dbService = DbService();
  final _authService = AuthService();
  
  final PageController _pageController = PageController();
  int _currentStep = 0; 

  bool _isEditing = false;
  String _activeEventId = "";  

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  
  final List<String> _boothSizes = ["Small", "Medium", "Large"];
  String _selectedSize = "Small"; 
  
  final _priceController = TextEditingController();
  final _slotsController = TextEditingController();
  
   // Keep them like this so they can be updated by your date pickers
// ignore: prefer_final_fields
DateTime _startDate = DateTime.now();
// ignore: prefer_final_fields
DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _slotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing 
            ? (_currentStep == 1 ? "Add Booths" : "Add Exhibition") 
            : "Manage Exhibitions"),
        centerTitle: true,
        leading: _isEditing && _currentStep == 1 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300), 
                  curve: Curves.easeInOut
                );
                setState(() => _currentStep = 0);
              },
            )
          : null,
      ),
      body: _isEditing 
          ? PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildForm(),
                _buildBoothForm(),
              ],
            )
          : _buildList(),
    );
  }

  // --- FIXED LIST VIEW: Fetches ORG-ID before loading stream ---
  Widget _buildList() {
    final String currentUserId = _authService.currentUser?.uid ?? "";
    
    return FutureBuilder<DocumentSnapshot>(
      // 1. Get the user profile to find the correct 'organizerId'
      future: FirebaseFirestore.instance.collection('users').doc(currentUserId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final String orgId = userData?['organizerId'] ?? "";

        return StreamBuilder<List<EventModel>>(
          // 2. Filter using the 'orgId' (ORG-xxxx) instead of 'uid'
          stream: _dbService.getOrganizerEvents(orgId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final events = snapshot.data ?? [];
            
            if (events.isEmpty) return const Center(child: Text("No exhibitions found. Check your Organizer ID."));

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
                          Switch(
                            value: event.isPublished,
                            activeThumbColor: Colors.green,
                            onChanged: (val) async {
                              setState(() => event.isPublished = val);
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
                  onPressed: () => setState(() { _isEditing = true; _currentStep = 0; }),
                  child: const Text("Add New Exhibition"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- STEP 1: ADD EXHIBITION ---
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepper(_currentStep + 1),
          const SizedBox(height: 30),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Exhibition Name", border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _locationController, decoration: const InputDecoration(labelText: "Location", border: OutlineInputBorder())),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              final String generatedId = const Uuid().v4(); 
              
              // 3. Ensure we save with the real ORG-xxxx ID
              final userDoc = await FirebaseFirestore.instance.collection('users').doc(_authService.currentUser?.uid).get();
              final String orgId = userDoc.data()?['organizerId'] ?? _authService.currentUser?.uid ?? "temp_organizer";

              final newEvent = EventModel(
                id: generatedId,
                name: _nameController.text,
                date: "${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}",
                location: _locationController.text,
                description: _descController.text,
                isPublished: false,
                organizerId: orgId, 
              );

              await _dbService.addEvent(newEvent);
              if (!mounted) return;
              _pageController.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
              setState(() { _activeEventId = generatedId; _currentStep = 1; });
            },
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  // --- STEP 2: ADD BOOTHS ---
  Widget _buildBoothForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepper(_currentStep + 1),
          const SizedBox(height: 30),
          DropdownButtonFormField<String>(
            initialValue: _selectedSize, 
            items: _boothSizes.map((size) => DropdownMenuItem(value: size, child: Text(size))).toList(),
            onChanged: (val) => setState(() => _selectedSize = val!),
            decoration: const InputDecoration(labelText: "Booth Type", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price (RM)", border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _slotsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Available Slots", border: OutlineInputBorder())),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await _dbService.addBoothType(_activeEventId, {
                'type': _selectedSize, 
                'price': _priceController.text,
                'slots': _slotsController.text,
              });
              if (!mounted) return; 
              _priceController.clear(); 
              _slotsController.clear();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booth Added Successfully!")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text("Add Booth Type", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => setState(() { _isEditing = false; _currentStep = 0; }),
            child: const Text("Finish & Exit"),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(int step) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _circleStep("Details", _currentStep >= 0, _currentStep == 0),
      _line(_currentStep >= 1),
      _circleStep("Booths", _currentStep >= 1, _currentStep == 1),
    ],
  );

  Widget _circleStep(String label, bool active, bool current) => Column(
    children: [
      CircleAvatar(
        radius: 12, 
        backgroundColor: active ? Colors.blue : Colors.blue.shade100,
        child: Text(active && !current ? "✓" : label[0], style: const TextStyle(fontSize: 10, color: Colors.white)),
      ),
      Text(label, style: const TextStyle(fontSize: 10))
    ]
  );

  Widget _line(bool active) => Container(width: 40, height: 2, margin: const EdgeInsets.only(bottom: 15), color: active ? Colors.blue : Colors.grey.shade300);
}