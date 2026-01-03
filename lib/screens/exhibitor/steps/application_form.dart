import 'package:flutter/material.dart';

class ApplicationForm extends StatefulWidget {
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onFormSubmitted;

  const ApplicationForm({
    super.key,
    required this.onBack,
    required this.onFormSubmitted, Map<String, dynamic>? initialData,
  });

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for all text fields
  final _nameController = TextEditingController();
  final _descController = TextEditingController(); // Added for Description
  final _profileController = TextEditingController(); // Added for Exhibit Profile

  // State for Add-ons
  final List<Map<String, dynamic>> _addons = [
    {'name': 'High-Speed WiFi', 'price': 150.0, 'selected': false},
    {'name': 'Extra Table', 'price': 50.0, 'selected': false},
    {'name': 'Electric Power Point', 'price': 100.0, 'selected': false},
    {'name': 'LED Spotlight', 'price': 80.0, 'selected': false},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onFormSubmitted({
        'details': {
          'companyName': _nameController.text,
          'description': _descController.text, // Added to data map
          'exhibitProfile': _profileController.text, // Added to data map
        },
        'addons': _addons.where((a) => a['selected'] == true).toList(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Company Details", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Company Name
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration("Company Name"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 15),

            // Company Description (New Field)
            TextFormField(
              controller: _descController,
              maxLines: 3, // Multi-line for description
              decoration: _buildInputDecoration("Company Description"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 15),

            // Exhibit Profile (New Field)
            TextFormField(
              controller: _profileController,
              maxLines: 2, // Multi-line for profile
              decoration: _buildInputDecoration("Exhibit Profile"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),

            const SizedBox(height: 30),
            const Text("Additional Items (Add-ons)", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Select items you need for your booth", 
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),

            // Add-ons List
            ..._addons.map((addon) => CheckboxListTile(
              title: Text(addon['name']),
              subtitle: Text("Price: RM ${addon['price'].toStringAsFixed(0)}"),
              value: addon['selected'],
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? value) {
                setState(() => addon['selected'] = value);
              },
            )),

            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: widget.onBack, child: const Text("BACK"))),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text("NEXT"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true, // Needed for multi-line fields
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}