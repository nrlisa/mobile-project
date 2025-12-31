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
  
  DateTime _startDate = DateTime.now();
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

  // Helper to select dates
  Future<void> _pickDate(bool isStart) async {
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
          // Ensure end date is not before start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Reset form when adding new event
  void _resetForm() {
    _nameController.clear();
    _locationController.clear();
    _descController.clear();
    _priceController.clear();
    _slotsController.clear();
    setState(() {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 1));
      _activeEventId = "";
      _isEditing = true;
      _currentStep = 0;
    });
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
          : (_isEditing 
              ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _isEditing = false)) 
              : null),
      ),
      // Floating Button to Add Event (Only on list view)
      floatingActionButton: !_isEditing 
          ? FloatingActionButton.extended(
              onPressed: _resetForm,
              icon: const Icon(Icons.add),
              label: const Text("Add Exhibition"),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ) 
          : null,
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

  // --- VIEW: EVENT LIST ---
  Widget _buildList() {
    final String currentUserId = _authService.currentUser?.uid ?? "";
    
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUserId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        
        // Robust ID Fetching: Check 'organizerId' first, fallback to UID
        final String orgId = userData != null && userData.containsKey('organizerId') 
            ? userData['organizerId'] 
            : currentUserId;

        return StreamBuilder<List<EventModel>>(
          stream: _dbService.getOrganizerEvents(orgId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final events = snapshot.data ?? [];
            
            if (events.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_note, size: 60, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text(
                        "No exhibitions found.",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text("ID: $orgId", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event.name, 
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Switch(
                              value: event.isPublished,
                              activeThumbColor: Colors.green,
                              activeTrackColor: Colors.green.shade200,
                              onChanged: (val) async {
                                setState(() => event.isPublished = val);
                                await _dbService.addEvent(event); 
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(event.date, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(event.location, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                              label: const Text("Delete", style: TextStyle(color: Colors.red)),
                              onPressed: () async {
                                await _dbService.deleteEvent(event.id);
                                if (!mounted) return;
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exhibition Deleted")));
                              },
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                // EDIT LOGIC: Load event and jump to booths
                                setState(() {
                                  _activeEventId = event.id;
                                  _isEditing = true;
                                  _currentStep = 1; 
                                });
                                Future.delayed(const Duration(milliseconds: 100), () {
                                   if (_pageController.hasClients) _pageController.jumpToPage(1);
                                });
                              },
                              child: const Text("Manage Booths"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- STEP 1: CREATE EVENT FORM ---
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
          const SizedBox(height: 16),
          
          // Date Pickers
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(true),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: "Start Date", border: OutlineInputBorder()),
                    child: Text("${_startDate.day}/${_startDate.month}/${_startDate.year}"),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(false),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: "End Date", border: OutlineInputBorder()),
                    child: Text("${_endDate.day}/${_endDate.month}/${_endDate.year}"),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder())),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              final String generatedId = const Uuid().v4(); 
              final userDoc = await FirebaseFirestore.instance.collection('users').doc(_authService.currentUser?.uid).get();
              
              // Consistent ID usage
              final String orgId = userDoc.data() != null && userDoc.data()!.containsKey('organizerId')
                  ? userDoc.data()!['organizerId'] 
                  : _authService.currentUser?.uid ?? "temp_organizer";

              String dateStr = "${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}";

              final newEvent = EventModel(
                id: generatedId,
                name: _nameController.text,
                date: dateStr,
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

  // --- STEP 2: MANAGE BOOTHS ---
  Widget _buildBoothForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepper(_currentStep + 1),
          const SizedBox(height: 30),
          
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedSize),
            initialValue: _selectedSize, 
            items: _boothSizes.map((size) => DropdownMenuItem(value: size, child: Text(size))).toList(),
            onChanged: (val) => setState(() => _selectedSize = val!),
            decoration: const InputDecoration(labelText: "Booth Type", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price (RM)", border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _slotsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantity (e.g. 10)", border: OutlineInputBorder())),
          const SizedBox(height: 30),
          
          ElevatedButton(
            onPressed: () async {
              if (_activeEventId.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No Active Event ID")));
                 return;
              }

              // This generates booths AND clears old ones (fixing data inconsistency)
              await _dbService.createBoothsBatch(
                _activeEventId,
                _selectedSize, 
                double.tryParse(_priceController.text) ?? 0.0,
                int.tryParse(_slotsController.text) ?? 1,
              );

              if (!mounted) return; 
              _priceController.clear(); 
              _slotsController.clear();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booths Generated (Old data overwritten)")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text("Generate Booths", style: TextStyle(color: Colors.white)),
          ),
          
          const SizedBox(height: 30),
          const Divider(),
          const Text("Current Inventory:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // LIVE INVENTORY TABLE (Matches Page 6 Requirement)
          StreamBuilder(
            stream: _dbService.getBoothsStream(_activeEventId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text("No booths added yet.");
              final booths = snapshot.data!; // Assumes DbService returns List<Booth>
              if (booths.isEmpty) return const Text("Inventory empty.");

              // Group by size for cleaner display
              Map<String, int> counts = {};
              Map<String, double> prices = {};
              for (var b in booths) {
                counts[b.size] = (counts[b.size] ?? 0) + 1;
                prices[b.size] = b.price;
              }

              return Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  const TableRow(decoration: BoxDecoration(color: Color(0xFFEEEEEE)), children: [
                    Padding(padding: EdgeInsets.all(8), child: Text("Type")),
                    Padding(padding: EdgeInsets.all(8), child: Text("Price")),
                    Padding(padding: EdgeInsets.all(8), child: Text("Count")),
                  ]),
                  ...counts.entries.map((e) => TableRow(children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text(e.key)),
                    Padding(padding: const EdgeInsets.all(8), child: Text("RM ${prices[e.key]}")),
                    Padding(padding: const EdgeInsets.all(8), child: Text("${e.value}")),
                  ])),
                ],
              );
            },
          ),

          const SizedBox(height: 30),
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