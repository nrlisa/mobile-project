import 'package:flutter/material.dart';

class BoothSelection extends StatefulWidget {
  final Function(String) onBoothSelected;
  final VoidCallback onBack;

  const BoothSelection({
    super.key,
    required this.onBoothSelected,
    required this.onBack, required String eventId,
  });

  @override
  State<BoothSelection> createState() => _BoothSelectionState();
}

class _BoothSelectionState extends State<BoothSelection> {
  String? _selectedBoothId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Halls A, B, and C
      child: Column(
        children: [
          // 1. Legend (Status Indicators)
          _buildLegend(),

          // 2. Hall Selection Tabs
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: "Hall A (Small)"),
              Tab(text: "Hall B (Medium)"),
              Tab(text: "Hall C (Large)"),
            ],
          ),

          // 3. Interactive Grid for each Hall
          Expanded(
            child: TabBarView(
              children: [
                _buildBoothGrid("A", "Small", 4, 1.0),   // Hall A: Small (Square)
                _buildBoothGrid("B", "Medium", 3, 1.3),  // Hall B: Medium (Rectangle)
                _buildBoothGrid("C", "Large", 2, 1.6),   // Hall C: Large (Wide Rectangle)
              ],
            ),
          ),

          // 4. Bottom Navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: widget.onBack, 
                  child: const Text("BACK", style: TextStyle(color: Colors.grey))
                ),
                ElevatedButton(
                  onPressed: _selectedBoothId == null
                      ? null
                      : () => widget.onBoothSelected(_selectedBoothId!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                  ),
                  child: const Text("NEXT"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.green, "Available"),
          const SizedBox(width: 15),
          _legendItem(Colors.red, "Booked"),
          const SizedBox(width: 15),
          _legendItem(Colors.blue, "Selected"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) => Row(
        children: [
          Container(
            width: 12, 
            height: 12, 
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      );

  Widget _buildBoothGrid(String hall, String size, int crossAxis, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("$size Booths in $hall", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxis, 
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: ratio, 
            ),
            itemCount: 12, // Example count per hall
            itemBuilder: (context, index) {
              String boothId = "$hall-${index + 1}";
              bool isBooked = index % 5 == 0; // Mock logic: every 5th booth is booked
              bool isSelected = _selectedBoothId == boothId;

              Color bgColor = isSelected 
                  ? Colors.blue 
                  : (isBooked ? Colors.red : Colors.green);

              return GestureDetector(
                onTap: isBooked ? null : () => _showBoothPopup(boothId, size),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                  child: Center(
                    child: Text(
                      boothId,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // POPUP DIALOG LOGIC
  void _showBoothPopup(String boothId, String size) {
    // Logic to determine price based on size
    String price = (size == "Small") ? "RM 1000" : (size == "Medium") ? "RM 2500" : "RM 5000";
    String dimensions = (size == "Small") ? "3m x 3m" : (size == "Medium") ? "5m x 5m" : "8m x 8m";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 10),
              Text("Booth $boothId"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Category:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("$size Booth"),
              const SizedBox(height: 10),
              const Text("Dimensions:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(dimensions),
              const SizedBox(height: 10),
              const Text("Price:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(price, style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 5),
                  Text("Status: Available", style: TextStyle(color: Colors.green)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedBoothId = boothId);
                Navigator.pop(context); // Close popup
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("SELECT BOOTH"),
            ),
          ],
        );
      },
    );
  }
}