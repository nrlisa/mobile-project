import 'package:flutter/material.dart';
import '../../../models/types.dart'; // Correct link to models

class ReviewApplication extends StatelessWidget {
  final Event event;
  final Booth booth;
  final ApplicationFormData formData;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const ReviewApplication({
    super.key,
    required this.event,
    required this.booth,
    required this.formData,
    required this.onSubmit,
    required this.onBack,
  });

  Map<String, double> calculateTotal() {
    double total = booth.price;
    // Mock prices logic
    if (formData.additionalItems.contains('Extra Chair (RM10)')) total += 10;
    if (formData.additionalItems.contains('Extra Table (RM25)')) total += 25;
    if (formData.additionalItems.contains('Spotlight (RM50)')) total += 50;
    
    final tax = total * 0.06;
    return {'sub': total, 'tax': tax, 'grand': total + tax};
  }

  @override
  Widget build(BuildContext context) {
    final totals = calculateTotal();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
      children: [
        const Text('Review Application', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Card 1: Company Info
        _borderedCard([
          _infoRow('Company Name', formData.companyName),
          const SizedBox(height: 16),
          _infoRow('Company Description', formData.companyDescription),
        ]),
        const SizedBox(height: 16),

        // Card 2: Exhibit Profile
        _borderedCard([
          _infoRow('Exhibit Profile', formData.exhibitProfile),
        ]),
        const SizedBox(height: 16),

        // Card 3: Event & Costs
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Start Date\n${event.date.split(' ')[0]}...', style: const TextStyle(fontSize: 14)),
                  Text('End Date\n15 Aug...', textAlign: TextAlign.right, style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Selected Booth:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('- ${booth.id} (${booth.type})', style: const TextStyle(fontSize: 14)),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(color: Colors.black),
              ),
              
              const Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              _costRow('Booth(s):', 'RM ${booth.price.toInt()}'),
              ...formData.additionalItems.map((item) => 
                _costRow('Add-Ons:', item.split('(')[1].replaceAll(')', ''))
              ),
              const SizedBox(height: 4),
              _costRow('Tax (6%):', 'RM ${totals['tax']!.toStringAsFixed(2)}'),
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('RM ${totals['grand']!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              )
            ],
          ),
        ),

        const SizedBox(height: 32),
        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: onBack,
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Back'),
            ),
            TextButton(
              onPressed: onSubmit,
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _borderedCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(value.isEmpty ? 'N/A' : value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _costRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}