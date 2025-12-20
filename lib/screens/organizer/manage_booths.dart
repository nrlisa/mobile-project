import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/db_service.dart';

class ManageBoothsScreen extends StatefulWidget {
  final String eventId; // Added to catch ID from Phase 2
  const ManageBoothsScreen({super.key, required this.eventId});

  @override
  State<ManageBoothsScreen> createState() => _ManageBoothsScreenState();
}

class _ManageBoothsScreenState extends State<ManageBoothsScreen> {
  bool _showForm = false;
  final _dbService = DbService();

  // Controllers to capture Phase 3 data
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _slotsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
            
            // --- THE PROGRESS STEPPER (PHASE 3) ---
            // Simplified to 2 steps as per your request
            _buildStepper(2), 
            
            const SizedBox(height: 30),
            _showForm ? _buildAddForm() : _buildList(),
          ],
        ),
      ),
    );
  }

  // Visual component for the 2-cycle progress bar
  Widget _buildStepper(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle("Add/Edit", currentStep >= 1),
        _stepLine(currentStep >= 2),
        _stepCircle("Manage Booth", currentStep >= 2),
      ],
    );
  }

  Widget _stepCircle(String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.lightBlue : Colors.blue.shade50, 
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: isActive ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _stepLine(bool isActive) {
    return Container(
      width: 50,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
      color: isActive ? Colors.grey.shade400 : Colors.grey.shade200,
    );
  }

  // Page 9: Dynamic Table View of Booths
  Widget _buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("List of Booths", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // Use StreamBuilder to show booths specifically for THIS event
        StreamBuilder<QuerySnapshot>(
          stream: _dbService.getBoothsForEvent(widget.eventId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
            
            final docs = snapshot.data?.docs ?? [];

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
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => setState(() => _showForm = true),
          child: const Text("Add New Booth Type"),
        ),
      ],
    );
  }

  // Page 8: Form View
  Widget _buildAddForm() {
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
          TextField(
            controller: _typeController,
            decoration: const InputDecoration(hintText: "Booth Type (e.g. Small, Medium)", filled: true, fillColor: Colors.white)
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("Price"),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "(RM)", filled: true, fillColor: Colors.white)
                )
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _slotsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Available Slots", filled: true, fillColor: Colors.white)
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => setState(() => _showForm = false), child: const Text("Cancel")),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  // Save Booth Type linked to specific eventID
                  await _dbService.addBoothType(widget.eventId, {
                    'type': _typeController.text,
                    'price': _priceController.text,
                    'slots': _slotsController.text,
                  });
                  
                  // Clear controllers and hide form
                  _typeController.clear();
                  _priceController.clear();
                  _slotsController.clear();
                  setState(() => _showForm = false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: const StadiumBorder()),
                child: const Text("Add Booth Type", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}