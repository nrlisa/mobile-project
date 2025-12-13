import 'package:flutter/material.dart';
import '../../../models/types.dart'; // Correct link to models

class ApplicationForm extends StatefulWidget {
  final Event event;
  final Booth booth;
  final Function(ApplicationFormData) onSubmit;
  final VoidCallback onBack;

  const ApplicationForm({
    super.key,
    required this.event,
    required this.booth,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  final formData = ApplicationFormData();
  final items = ['Extra Chair (RM10)', 'Extra Table (RM25)', 'Spotlight (RM50)'];

  void handleChange(String field, String value) {
    setState(() {
      if (field == 'companyName') formData.companyName = value;
      if (field == 'companyDescription') formData.companyDescription = value;
      if (field == 'exhibitProfile') formData.exhibitProfile = value;
    });
  }

  void handleCheckbox(String item) {
    setState(() {
      if (formData.additionalItems.contains(item)) {
        formData.additionalItems.remove(item);
      } else {
        formData.additionalItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
      children: [
        const Text('Application Form', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),

        _buildInput('Company Name', formData.companyName, (v) => handleChange('companyName', v)),
        _buildInput('Company Description', formData.companyDescription, (v) => handleChange('companyDescription', v)),
        _buildInput('Exhibit Profile', formData.exhibitProfile, (v) => handleChange('exhibitProfile', v)),

        // Read-only Event Data
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Event', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _readOnlyBox('Start Date', widget.event.date.split(' ')[0])),
                  const SizedBox(width: 16),
                  Expanded(child: _readOnlyBox('End Date', '15 Aug 2025')),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selected Booth
        const Text('Selected Booth', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${widget.booth.id} (${widget.booth.type}) - RM${widget.booth.price.toInt()}',
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        const SizedBox(height: 16),

        // Additional Items
        const Text('Additional Items', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Column(
          children: items.map((item) {
            final isChecked = formData.additionalItems.contains(item);
            return Row(
              children: [
                SizedBox(
                  width: 24, height: 24,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (_) => handleCheckbox(item),
                    activeColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 4),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey, style: BorderStyle.solid)), 
                    ),
                    child: Text(item, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ),
                )
              ],
            );
          }).toList(),
        ),

        const SizedBox(height: 32),

        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: widget.onBack,
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Back'),
            ),
            TextButton(
              onPressed: () => widget.onSubmit(formData),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInput(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Colors.black)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}