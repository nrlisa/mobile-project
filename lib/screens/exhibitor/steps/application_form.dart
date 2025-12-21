import 'package:flutter/material.dart';

class ApplicationForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormSubmitted;
  final VoidCallback onBack;

  const ApplicationForm({super.key, required this.onFormSubmitted, required this.onBack});

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  
  // List of available additional items
  final List<Map<String, dynamic>> _availableAddons = [
    {'name': 'High-Speed WiFi', 'price': 150.0},
    {'name': 'Extra Table', 'price': 50.0},
    {'name': 'Electric Power Point', 'price': 100.0},
    {'name': 'LED Spotlight', 'price': 80.0},
  ];

  final Set<int> _selectedIndices = {};
  final Map<String, String> _companyDetails = {
    'companyName': '',
    'description': '',
    'exhibitProfile': '',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Company Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextFormField(
              decoration: const InputDecoration(labelText: "Company Name", border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "Required" : null,
              onSaved: (v) => _companyDetails['companyName'] = v!,
            ),
            const SizedBox(height: 25),

            const Text("Additional Items (Add-ons)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Select items you need for your booth", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),

            // Checkbox list for Add-ons
            ...List.generate(_availableAddons.length, (index) {
              final item = _availableAddons[index];
              return CheckboxListTile(
                title: Text(item['name']),
                subtitle: Text("Price: RM ${item['price']}"),
                value: _selectedIndices.contains(index),
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked == true) _selectedIndices.add(index);
                    else _selectedIndices.remove(index);
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
            
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: widget.onBack, child: const Text("BACK")),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      
                      // Filter selected items to pass to next step
                      List<Map<String, dynamic>> selectedAddons = _selectedIndices
                          .map((i) => _availableAddons[i])
                          .toList();

                      widget.onFormSubmitted({
                        'details': _companyDetails,
                        'addons': selectedAddons,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("NEXT"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}