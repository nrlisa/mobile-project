import 'package:flutter/material.dart';
// ignore: unused_import
import '../../utils/app_theme.dart';

class ManageBoothsScreen extends StatefulWidget {
  const ManageBoothsScreen({super.key});

  @override
  State<ManageBoothsScreen> createState() => _ManageBoothsScreenState();
}

class _ManageBoothsScreenState extends State<ManageBoothsScreen> {
  // Toggle for demo purposes (List vs Add)
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Booths"),
        actions: [
          if (!_showForm)
            IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _showForm = true))
        ],
      ),
      body: _showForm ? _buildAddForm() : _buildList(),
    );
  }

  // Page 9: List of Booth Types
  Widget _buildList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("List of Booths", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
            children: const [
              TableRow(
                decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text("Booth Type", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(8.0), child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(8.0), child: Text("Slots", style: TextStyle(fontWeight: FontWeight.bold))),
                ]
              ),
              TableRow(children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text("Small")),
                Padding(padding: EdgeInsets.all(8.0), child: Text("RM 300")),
                Padding(padding: EdgeInsets.all(8.0), child: Text("15")),
              ]),
              TableRow(children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text("Medium")),
                Padding(padding: EdgeInsets.all(8.0), child: Text("RM 600")),
                Padding(padding: EdgeInsets.all(8.0), child: Text("20")),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  // Page 8: Add New Booth Type Form
  Widget _buildAddForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add New Booth Type", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const TextField(decoration: InputDecoration(labelText: "Booth Type (e.g. Small)")),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: "Price (RM)")),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: "Available Slots")),
          const SizedBox(height: 30),
          Row(children: [
             Expanded(child: OutlinedButton(onPressed: () => setState(() => _showForm = false), child: const Text("Cancel"))),
             const SizedBox(width: 16),
             Expanded(child: ElevatedButton(onPressed: () => setState(() => _showForm = false), child: const Text("Add Booth Type"))),
          ]),
        ],
      ),
    );
  }
}