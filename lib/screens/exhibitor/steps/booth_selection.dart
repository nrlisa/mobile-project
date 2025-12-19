import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
class BoothSelection extends StatelessWidget {
  final Function(String) onBoothSelected;

  const BoothSelection({super.key, required this.onBoothSelected, required void Function() onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search booth",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(Colors.blue, "Selected"),
              _buildLegendItem(AppTheme.successGreen, "Available"),
              _buildLegendItem(AppTheme.warningAmber, "Reserved"),
              _buildLegendItem(AppTheme.errorRed, "Booked"),
            ],
          ),
          const SizedBox(height: 20),

          const Text("Hall A - Small Booths", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Grid of Booths - Matches Wireframe Page 13
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildBoothItem("A-01", "RM1000", AppTheme.successGreen), // Available
              _buildBoothItem("A-02", "RM1000", AppTheme.errorRed),    // Booked
              _buildBoothItem("A-03", "RM1000", AppTheme.errorRed),    // Booked
              _buildBoothItem("A-04", "RM1000", AppTheme.warningAmber),// Reserved
              
              _buildBoothItem("B-01", "RM2500", AppTheme.successGreen),
              _buildBoothItem("B-02", "RM2500", AppTheme.warningAmber),
              _buildBoothItem("B-03", "RM2500", AppTheme.successGreen),
              _buildBoothItem("B-04", "RM2500", AppTheme.errorRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildBoothItem(String id, String price, Color color) {
    return GestureDetector(
      onTap: () {
         if (color == AppTheme.successGreen) {
           onBoothSelected(id);
         }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(price, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}