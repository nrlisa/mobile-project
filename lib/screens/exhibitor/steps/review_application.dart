import 'package:flutter/material.dart';
import '../../../models/types.dart';

class ReviewApplication extends StatelessWidget {
  final Event? selectedEvent; 
  final String boothId;
  final Map<String, dynamic> formData;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const ReviewApplication({
    super.key,
    this.selectedEvent,
    required this.boothId,
    required this.formData,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // [Inference] Handling potential null nested maps from the application form
    final details = formData['details'] as Map<String, dynamic>? ?? {};
    final addons = formData['addons'] as List<dynamic>? ?? [];

    // Pricing Logic
    double boothPrice = boothId.startsWith('A') ? 1000.0 : boothId.startsWith('B') ? 2500.0 : 5000.0;
    double addonsTotal = addons.fold(0.0, (sum, item) => sum + (item['price'] ?? 0.0));
    double tax = (boothPrice + addonsTotal) * 0.06; 
    double grandTotal = boothPrice + addonsTotal + tax;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Review Application", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // 1. Company Info Box
          _buildWireframeBox("Company Name", details['companyName'] ?? 'Not specified', 
              subTitle: "Company Description", subContent: details['description'] ?? 'No description provided'),

          const SizedBox(height: 15),

          // 2. Exhibit Profile Box
          _buildWireframeBox("Exhibit Profile", details['exhibitProfile'] ?? 'No profile provided'),

          const SizedBox(height: 15),

          // 3. Event & Pricing Summary Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(color: Colors.black, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dateColumn("Start Date", selectedEvent?.date.split('-')[0].trim() ?? ".........."),
                    _dateColumn("End Date", (selectedEvent?.date.contains('-') ?? false) 
                        ? selectedEvent!.date.split('-')[1].trim() : ".........."),
                  ],
                ),
                const SizedBox(height: 15),
                const Text("Selected Booth:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("- $boothId"),
                const SizedBox(height: 15),
                const Text("Summary:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                _summaryRow("Booth(s):", "RM ${boothPrice.toStringAsFixed(2)}"),
                ...addons.map((item) => _summaryRow("${item['name']}:", "RM ${item['price'].toStringAsFixed(2)}")),
                _summaryRow("Tax (6%):", "RM ${tax.toStringAsFixed(2)}"),
                const SizedBox(height: 10),
                const Divider(color: Colors.black, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Grand Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("RM ${grandTotal.toStringAsFixed(2)}", 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Navigation Buttons
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: onBack, child: const Text("BACK"))),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSubmit, // This now triggers the payment page in the flow screen
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  // CHANGE MADE HERE: Updated label to "NEXT" to show there's a following step
                  child: const Text("NEXT"), 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWireframeBox(String title, String content, {String? subTitle, String? subContent}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 15)),
          if (subTitle != null) ...[
            const SizedBox(height: 15),
            Text(subTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subContent ?? '', style: const TextStyle(fontSize: 15)),
          ]
        ],
      ),
    );
  }

  Widget _dateColumn(String label, String date) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(date),
    ],
  );

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value),
      ],
    ),
  );
}