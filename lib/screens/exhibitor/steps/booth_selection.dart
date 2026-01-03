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
        final hallABooths = booths.where((b) => b.size == 'Small' || b.boothNumber.startsWith('S')).toList()..sort(_compareBoothNumbers);
        final hallBBooths = booths.where((b) => b.size == 'Medium' || b.boothNumber.startsWith('M')).toList()..sort(_compareBoothNumbers);
        final hallCBooths = booths.where((b) => b.size == 'Large' || b.boothNumber.startsWith('L')).toList()..sort(_compareBoothNumbers);

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

  int _compareBoothNumbers(Booth a, Booth b) {
    try {
      final int aNum = int.parse(a.boothNumber.split('-').last);
      final int bNum = int.parse(b.boothNumber.split('-').last);
      return aNum.compareTo(bNum);
    } catch (e) {
      return a.boothNumber.compareTo(b.boothNumber);
    }
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
    final isAvailable = booth.status.toLowerCase() == 'available';
    String dimensions = (booth.size == "Small") ? "3m x 3m" : (booth.size == "Medium") ? "5m x 5m" : "8m x 8m";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    "Booth ${booth.boothNumber}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    "RM ${booth.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Details
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Category", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("${booth.size} Booth", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Dimensions", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(dimensions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Status
                  Row(
                    children: [
                      Icon(
                        isAvailable ? Icons.check_circle : Icons.error,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAvailable ? "Available" : "Unavailable",
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isAvailable
                        ? () {
                            setState(() => _selectedBooth = booth);
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[500],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("SELECT BOOTH"),
                  ),
                ],
              ),
            ),
          ],
        ),
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