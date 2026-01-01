import 'package:flutter/material.dart';
import '../../../services/db_service.dart';
import '../../../models/booth.dart';

class BoothSelection extends StatefulWidget {
  final String eventId; // Added eventId to fetch specific booths
  final Function(String) onBoothSelected;
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

        // Filter booths by Hall/Size logic
        // Logic: 'S' prefix -> Hall A, 'M' prefix -> Hall B, 'L' prefix -> Hall C
        final hallABooths = booths.where((b) => b.size == 'Small' || b.boothNumber.startsWith('S')).toList();
        final hallBBooths = booths.where((b) => b.size == 'Medium' || b.boothNumber.startsWith('M')).toList();
        final hallCBooths = booths.where((b) => b.size == 'Large' || b.boothNumber.startsWith('L')).toList();

        return DefaultTabController(
          length: 3, 
          child: Column(
            children: [
              // 1. Legend
              _buildLegend(),

              // 2. Tabs
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

              // 3. Grids
              Expanded(
                child: TabBarView(
                  children: [
                    _buildBoothGrid("A", "Small", 4, 1.0, hallABooths),
                    _buildBoothGrid("B", "Medium", 3, 1.3, hallBBooths),
                    _buildBoothGrid("C", "Large", 2, 1.6, hallCBooths),
                  ],
                ),
              ),

              // 4. Navigation
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: widget.onBack,
                      child: const Text("BACK", style: TextStyle(color: Colors.grey)),
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
      },
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
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      );

  Widget _buildBoothGrid(String hall, String sizeLabel, int crossAxis, double ratio, List<Booth> booths) {
    if (booths.isEmpty) {
      return Center(child: Text("No $sizeLabel booths available in Hall $hall"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("$sizeLabel Booths in $hall",
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
            itemCount: booths.length,
            itemBuilder: (context, index) {
              final booth = booths[index];
              bool isBooked = booth.status.toLowerCase() == 'booked';
              bool isSelected = _selectedBoothId == booth.id;

              Color bgColor = isSelected
                  ? Colors.blue
                  : (isBooked ? Colors.red : Colors.green);

              return GestureDetector(
                onTap: isBooked ? null : () => _showBoothPopup(booth),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          booth.boothNumber,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (!isBooked)
                          Text(
                            "RM${booth.price.toInt()}",
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                      ],
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

  void _showBoothPopup(Booth booth) {
    String dimensions = (booth.size == "Small") ? "3m x 3m" : (booth.size == "Medium") ? "5m x 5m" : "8m x 8m";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 10),
              Text("Booth ${booth.boothNumber}"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Category:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${booth.size} Booth"),
              const SizedBox(height: 10),
              const Text("Dimensions:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(dimensions),
              const SizedBox(height: 10),
              const Text("Price:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("RM ${booth.price.toStringAsFixed(2)}", 
                  style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 5),
                  Text("Status: ${booth.status}", style: const TextStyle(color: Colors.green)),
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
                setState(() => _selectedBoothId = booth.id);
                Navigator.pop(context);
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