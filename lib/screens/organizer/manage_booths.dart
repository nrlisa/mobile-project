import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/db_service.dart';
import '../../models/event_model.dart';

class ManageBoothsScreen extends StatefulWidget {
  final String eventId; 
  const ManageBoothsScreen({super.key, required this.eventId});

  @override
  State<ManageBoothsScreen> createState() => _ManageBoothsScreenState();
}

class _ManageBoothsScreenState extends State<ManageBoothsScreen> {
  bool _showForm = false;
  final _dbService = DbService();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _slotsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // --- UPDATED FIX: Use effectiveId with Fallback ---
    final String effectiveId = widget.eventId.isEmpty 
        ? (DbService.currentEventId ?? "") 
        : widget.eventId;

    // Safety check for empty path
    if (effectiveId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const Text("Error: Event ID is missing from memory and pass."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Booth", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(child: Text("Organizer", style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 20),
            _buildStepper(2), 
            const SizedBox(height: 30),

            // Toggle between the Add Form and the Multi-Exhibition List
            _showForm ? _buildAddForm(effectiveId) : _buildMultiExhibitionList(),

            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Exhibition and Booths Saved Successfully")),
                      );
                    },
                    child: const Text("Save & Finish"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW: DISPLAYS ALL ORGANIZER EVENTS WITH THEIR BOOTHS ---
  Widget _buildMultiExhibitionList() {
    // Use the current Auth UID to fetch all designated exhibitions
    final String currentUid = DbService.currentEventId != null ? "vILKJ3YVHFUFGrnpJ6NDiH1G4V12" : ""; 

    return StreamBuilder<List<EventModel>>(
      // Logic from Phase 2 to get organizer-specific events
      stream: _dbService.getOrganizerEvents(currentUid), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(child: Text("No exhibitions found to manage."));
        }

        return Column(
          children: [
            const Text("Designated List of Booths", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EXHIBITION HEADER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text("Event: ${event.name}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    const SizedBox(height: 10),
                    // BOOTH TABLE FOR THIS EVENT
                    _buildBoothTable(event.id),
                    const SizedBox(height: 20),
                    const Divider(),
                  ],
                );
              },
            ),
            ElevatedButton(
              onPressed: () => setState(() => _showForm = true),
              child: const Text("Add New Booth Type"),
            ),
          ],
        );
      },
    );
  }

  // REUSABLE BOOTH TABLE COMPONENT
  Widget _buildBoothTable(String id) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.getBoothsForEvent(id),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Text("  No booths added for this event.");

        return Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text("Booth Type", style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(8.0), child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(8.0), child: Text("Slots", style: TextStyle(fontWeight: FontWeight.bold))),
              ]
            ),
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return TableRow(children: [
                Padding(padding: const EdgeInsets.all(8.0), child: Text(data['type'] ?? "")),
                Padding(padding: const EdgeInsets.all(8.0), child: Text("RM ${data['price']}")),
                Padding(padding: const EdgeInsets.all(8.0), child: Text(data['slots'] ?? "0")),
              ]);
            }),
          ],
        );
      }
    );
  }

  Widget _buildAddForm(String id) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add New Booth Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: _typeController, decoration: const InputDecoration(hintText: "Type", filled: true, fillColor: Colors.white)),
          const SizedBox(height: 16),
          TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Price (RM)", filled: true, fillColor: Colors.white)),
          const SizedBox(height: 16),
          TextField(controller: _slotsController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Slots", filled: true, fillColor: Colors.white)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => setState(() => _showForm = false), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  await _dbService.addBoothType(id, {
                    'type': _typeController.text,
                    'price': _priceController.text,
                    'slots': _slotsController.text,
                  });
                  _typeController.clear(); _priceController.clear(); _slotsController.clear();
                  setState(() => _showForm = false);
                },
                child: const Text("Add Booth"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(int step) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _stepCircle("Add/Edit", step >= 1),
      _stepLine(step >= 2),
      _stepCircle("Manage Booth", step >= 2),
    ],
  );

  Widget _stepCircle(String label, bool isActive) => Column(
    children: [
      Container(
        width: 35, height: 35,
        decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? Colors.lightBlue : Colors.blue.shade50, border: Border.all(color: Colors.blue.shade100)),
        child: isActive ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 10)),
    ],
  );

  Widget _stepLine(bool isActive) => Container(width: 50, height: 2, color: isActive ? Colors.grey.shade400 : Colors.grey.shade200);
} 