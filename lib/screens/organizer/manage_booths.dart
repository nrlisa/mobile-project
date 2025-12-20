import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/db_service.dart';

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
    // --- ADDED: CHECK FOR EMPTY PATH ---
    // This prevents the "Invalid argument(s): A document path must be a non-empty string" error
    if (widget.eventId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(
          child: Text("Error: Event ID is missing. Please go back and try again."),
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
            _showForm ? _buildAddForm() : _buildList(),

            // --- ADDED: BACK & SAVE & FINISH BUTTONS ---
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
                      // Finalizes the flow and returns to the Exhibition List
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

  Widget _buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("List of Booths", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // StreamBuilder ensures the list is filtered by the current Event ID
        StreamBuilder<QuerySnapshot>(
          stream: _dbService.getBoothsForEvent(widget.eventId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            
            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No booth types added yet.", style: TextStyle(color: Colors.grey))),
              );
            }

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
                  if (_typeController.text.isEmpty || _priceController.text.isEmpty) return;

                  // Saves to sub-collection of specific eventID
                  await _dbService.addBoothType(widget.eventId, {
                    'type': _typeController.text,
                    'price': _priceController.text,
                    'slots': _slotsController.text,
                  });
                  
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