import 'package:flutter/material.dart';
import '../../../services/db_service.dart';
import '../../../models/booth.dart';

class BoothSelection extends StatefulWidget {
  final String eventId; // Ensure this is passed from the parent
  final Function(Booth) onBoothSelected; // Changed from String to Booth object for better data flow
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
  final DbService _dbService = DbService();
  Booth? _selectedBooth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Booth>>(
      stream: _dbService.getBoothsStream(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error loading booths: ${snapshot.error}"));
        }

        final booths = snapshot.data ?? [];

        // Filter booths by Hall/Size logic
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
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: "Hall A (Small)"),
                  Tab(text: "Hall B (Medium)"),
                  Tab(text: "Hall C (Large)"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildBoothGrid(hallABooths),
                    _buildBoothGrid(hallBBooths),
                    _buildBoothGrid(hallCBooths),
                  ],
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoothGrid(List<Booth> booths) {
    if (booths.isEmpty) {
      return const Center(child: Text("No booths available in this hall"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: booths.length,
      itemBuilder: (context, index) {
        final booth = booths[index];
        bool isSelected = _selectedBooth?.id == booth.id;
        bool isBooked = booth.status.toLowerCase() == 'booked';

        Color bgColor = isSelected 
            ? Colors.blue 
            : (isBooked ? Colors.red : Colors.green);

        return GestureDetector(
          onTap: isBooked ? null : () => _showBoothPopup(booth),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                booth.boothNumber,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBoothPopup(Booth booth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Booth ${booth.boothNumber}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Size: ${booth.size}"),
            Text("Price: RM ${booth.price}"),
            Text("Status: ${booth.status}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              setState(() => _selectedBooth = booth);
              Navigator.pop(context);
            },
            child: const Text("SELECT"),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(onPressed: widget.onBack, child: const Text("BACK")),
          ElevatedButton(
            onPressed: _selectedBooth == null ? null : () => widget.onBoothSelected(_selectedBooth!),
            child: const Text("NEXT"),
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
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      );
}