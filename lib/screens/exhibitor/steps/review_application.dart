import 'package:flutter/material.dart';

class ReviewApplication extends StatelessWidget {
  final String boothId;
  final Map<String, dynamic> formData;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const ReviewApplication({
    super.key,
    required this.boothId,
    required this.formData,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final details = formData['details'] as Map<String, String>;
    final addons = formData['addons'] as List<Map<String, dynamic>>;

    // Pricing Logic
    double boothPrice = boothId.startsWith('A') ? 1000.0 : boothId.startsWith('B') ? 2500.0 : 5000.0;
    double addonsTotal = addons.fold(0.0, (sum, item) => sum + item['price']);
    double grandTotal = boothPrice + addonsTotal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Review Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          
          _buildRow("Company", details['companyName'] ?? ''),
          _buildRow("Booth No", boothId),
          _buildRow("Base Booth Price", "RM $boothPrice"),
          
          if (addons.isNotEmpty) ...[
            const SizedBox(height: 15),
            const Text("Additional Items:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ...addons.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("• ${item['name']}", style: const TextStyle(fontSize: 14)),
                  Text("RM ${item['price']}", style: const TextStyle(fontSize: 14)),
                ],
              ),
            )),
          ],

          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("GRAND TOTAL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("RM $grandTotal", style: const TextStyle(fontSize: 22, color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(onPressed: onBack, child: const Text("BACK")),
              ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text("SUBMIT APPLICATION"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}