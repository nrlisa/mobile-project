import 'package:flutter/material.dart';
import '../../models/booth.dart'; // Ensure this matches your project structure

class BoothSelectionMap extends StatefulWidget {
  final List<Booth> booths;
  final Function(Booth?) onBoothSelected;

  const BoothSelectionMap({
    super.key,
    required this.booths,
    required this.onBoothSelected,
  });

  @override
  State<BoothSelectionMap> createState() => _BoothSelectionMapState();
}

class _BoothSelectionMapState extends State<BoothSelectionMap> {
  String? _selectedBoothId;

  // 1. Map Booth Numbers to Hall Names (Logic: S=Hall A, M=Hall B, L=Hall C)
  String _getHallName(Booth booth) {
    if (booth.boothNumber.contains('-')) {
      final prefix = booth.boothNumber.split('-').first.toUpperCase();
      switch (prefix) {
        case 'S': return "A (Small)";
        case 'M': return "B (Medium)";
        case 'L': return "C (Large)";
        default: return prefix; 
      }
    }
    return "Main Hall";
  }

  // 2. Group booths by Hall
  Map<String, List<Booth>> get _boothsByHall {
    final Map<String, List<Booth>> grouped = {};
    
    // Sort booths by number first to ensure order (S-1, S-2...)
    final sortedBooths = List<Booth>.from(widget.booths)
      ..sort((a, b) => a.boothNumber.compareTo(b.boothNumber));

    for (final booth in sortedBooths) {
      final hall = _getHallName(booth);
      if (!grouped.containsKey(hall)) {
        grouped[hall] = [];
      }
      grouped[hall]!.add(booth);
    }
    
    // Sort keys so Hall A appears before Hall B
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  void _handleBoothTap(Booth booth) {
    // Block selection if not available
    if (booth.status.toLowerCase() != 'available') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booth ${booth.boothNumber} is ${booth.status}."),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      if (_selectedBoothId == booth.id) {
        _selectedBoothId = null;
        widget.onBoothSelected(null);
      } else {
        _selectedBoothId = booth.id;
        widget.onBoothSelected(booth);
        _showBoothDetailsModal(context, booth);
      }
    });
  }

  Color _getBoothColor(Booth booth) {
    if (_selectedBoothId == booth.id) {
      return Colors.blue; // Selected
    }
    switch (booth.status.toLowerCase()) {
      case 'available':
        return Colors.green.shade300;
      case 'booked':
        return Colors.red.shade300;
      case 'reserved':
        return Colors.orange.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.booths.isEmpty) {
      return const Center(child: Text("No booths available."));
    }

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.5,
      maxScale: 4.0,
      constrained: false, // Allows scrolling beyond screen bounds
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _boothsByHall.entries.map((entry) {
            final hallName = entry.key;
            final booths = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Hall Header ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blueGrey.shade200),
                    ),
                    child: Text(
                      "Hall $hallName",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
                
                // --- Booth Grid ---
                SizedBox(
                  width: 600, // Fixed width for consistent map feel
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6, // 6 booths per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: booths.length,
                    itemBuilder: (context, index) {
                      final booth = booths[index];
                      return GestureDetector(
                        onTap: () => _handleBoothTap(booth),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _getBoothColor(booth),
                            borderRadius: BorderRadius.circular(4),
                            border: _selectedBoothId == booth.id
                                ? Border.all(color: Colors.blue.shade900, width: 3)
                                : Border.all(color: Colors.white, width: 1),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              )
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  booth.boothNumber, 
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                if (booth.status.toLowerCase() == 'available')
                                  Text(
                                    'RM${booth.price.toInt()}',
                                    style: const TextStyle(fontSize: 8, color: Colors.white),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30), // Spacing between halls
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBoothDetailsModal(BuildContext context, Booth booth) {
    // Helper to generate display data based on size
    String dimensions = "3m x 3m";
    List<String> features = ["Standard Power Socket", "1 Table, 2 Chairs"];

    if (booth.size == 'Medium') {
      dimensions = "5m x 5m";
      features = ["2 Power Sockets", "2 Tables, 4 Chairs", "Spotlights"];
    } else if (booth.size == 'Large') {
      dimensions = "8m x 8m";
      features = ["4 Power Sockets", "Meeting Area", "Counter", "Carpeted"];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booth ${booth.boothNumber}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                '${booth.size} Booth',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: booth.status.toLowerCase() == 'available' ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booth.status.toUpperCase(),
                      style: TextStyle(
                        color: booth.status.toLowerCase() == 'available' ? Colors.green[800] : Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'RM${booth.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Dimensions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(dimensions, style: const TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 16),
              const Text('Included Features', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(feature),
                  ],
                ),
              )),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                   // Selection logic is handled in parent, just close modal
                   Navigator.pop(context);
                }, 
                child: const Text("CONFIRM SELECTION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      },
    );
  }
}