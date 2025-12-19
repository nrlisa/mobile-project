import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ManageExhibitionsScreen extends StatefulWidget {
  const ManageExhibitionsScreen({super.key});

  @override
  State<ManageExhibitionsScreen> createState() => _ManageExhibitionsScreenState();
}

class _ManageExhibitionsScreenState extends State<ManageExhibitionsScreen> {
  bool _isEditing = false; // Toggle between List and Form view

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Add Exhibition" : "Manage Exhibitions"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isEditing) {
              setState(() => _isEditing = false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _isEditing ? _buildForm() : _buildList(),
    );
  }

  // Page 6: List View
  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Example Item from Wireframe
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Global Tech Expo 2025", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("1-3 August 2025"),
              const Text("Quill City Mall"),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton.icon(icon: const Icon(Icons.edit, size: 16), label: const Text("Edit"), onPressed: () => setState(() => _isEditing = true)),
                  TextButton.icon(icon: const Icon(Icons.delete, size: 16, color: Colors.red), label: const Text("Delete", style: TextStyle(color: Colors.red)), onPressed: () {}),
                  const Spacer(),
                  Switch(value: true, onChanged: (val) {}, activeThumbColor: AppTheme.successGreen), // Publish Toggle
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => setState(() => _isEditing = true),
          child: const Text("Add"),
        ),
      ],
    );
  }

  // Page 7: Form View
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TextField(decoration: InputDecoration(labelText: "Exhibition Name")),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: "Add Details")),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextField(decoration: InputDecoration(labelText: "Start Date", suffixIcon: Icon(Icons.calendar_today)))),
            SizedBox(width: 16),
            Expanded(child: TextField(decoration: InputDecoration(labelText: "End Date", suffixIcon: Icon(Icons.calendar_today)))),
          ]),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: "Location")),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: "Description"), maxLines: 3),
          const SizedBox(height: 30),
          Row(children: [
             Expanded(child: OutlinedButton(onPressed: () => setState(() => _isEditing = false), child: const Text("Cancel"))),
             const SizedBox(width: 16),
             Expanded(child: ElevatedButton(onPressed: () => setState(() => _isEditing = false), child: const Text("Save"))),
          ]),
        ],
      ),
    );
  }
}