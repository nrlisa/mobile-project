import 'package:flutter/material.dart';
import '../../../models/booth.dart'; 
import '../../../services/db_service.dart';

class BoothSelection extends StatefulWidget {
  final String eventId; 
  final Function(Booth) onBoothSelected; // FIXED: Change String to Booth
  final VoidCallback onBack;

  const BoothSelection({
    super.key,
    required this.eventId, 
    required this.onBoothSelected,
    required this.onBack,
  });

  @override
  State<BoothSelection> createState() => _BoothSelectionState();
}

class _BoothSelectionState extends State<BoothSelection> {
  String? _selectedBoothId;
  Booth? _selectedBoothObject; 
  final DbService _dbService = DbService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Booth>>(
      stream: _dbService.getBoothsStream(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final booths = snapshot.data ?? [];

        final hallABooths = booths.where((b) => b.size == 'Small' || b.boothNumber.startsWith('S')).toList();
        final hallBBooths = booths.where((b) => b.size == 'Medium' || b.boothNumber.startsWith('M')).toList();
        final hallCBooths = booths.where((b) => b.size == 'Large' || b.boothNumber.startsWith('L')).toList();

        return DefaultTabController(
          length: 3, 
          child: Column(
            children: [
              _buildLegend(),
              const TabBar(
                labelColor: Colors.blue,
                tabs: [
                  Tab(text: "Hall A (Small)"),
                  Tab(text: "Hall B (Medium)"),
                  Tab(text: "Hall C (Large)"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildBoothGrid("A", "Small", 4, 1.0, hallABooths),
                    _buildBoothGrid("B", "Medium", 3, 1.3, hallBBooths),
                    _buildBoothGrid("C", "Large", 2, 1.6, hallCBooths),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: widget.onBack, child: const Text("BACK")),
                    ElevatedButton(
                      onPressed: _selectedBoothObject == null
                          ? null
                          : () => widget.onBoothSelected(_selectedBoothObject!), // FIXED: Pass the object
                      child: const Text("NEXT"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoothGrid(String hall, String sizeLabel, int crossAxis, double ratio, List<Booth> booths) {
    if (booths.isEmpty) return const Center(child: Text("No booths found."));
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        childAspectRatio: ratio,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: booths.length, // Uses real Firebase count
      itemBuilder: (context, index) {
        final booth = booths[index];
        bool isBooked = booth.status.toLowerCase() == 'booked';
        bool isSelected = _selectedBoothId == booth.id;

        return GestureDetector(
          onTap: isBooked ? null : () => _showBoothPopup(booth),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : (isBooked ? Colors.red.shade100 : Colors.green.shade100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(booth.boothNumber)), // Real Number
          ),
        );
      },
    );
  }

  void _showBoothPopup(Booth booth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Booth ${booth.boothNumber}"),
        content: Text("Price: RM ${booth.price}\nSize: ${booth.size}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedBoothId = booth.id;
                _selectedBoothObject = booth;
              });
              Navigator.pop(context);
            },
            child: const Text("Select"),
          )
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.green.shade100, "Available"),
        _legendItem(Colors.red.shade100, "Booked"),
        _legendItem(Colors.blue, "Selected"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) => Row(children: [
    Container(width: 12, height: 12, color: color),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 10)),
    const SizedBox(width: 10),
  ]);
}