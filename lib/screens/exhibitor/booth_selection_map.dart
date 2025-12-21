import 'package:flutter/material.dart';
import '../../models/types.dart';

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

  Map<String, List<Booth>> get _boothsByHall {
    final Map<String, List<Booth>> grouped = {};
    for (final booth in widget.booths) {
      if (!grouped.containsKey(booth.hall)) {
        grouped[booth.hall] = [];
      }
      grouped[booth.hall]!.add(booth);
    }
    return grouped;
  }

  void _handleBoothTap(Booth booth) {
    // Only allow selection if available
    if (booth.status != 'available') return;

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
      return Colors.blue;
    }
    switch (booth.status) {
      case 'available':
        return Colors.green[300]!;
      case 'booked':
        return Colors.red[300]!;
      case 'reserved':
        // Updated to Orange for reserved status
        return Colors.orange[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.5,
      maxScale: 4.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Hall $hallName",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 600,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
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
                                    ? Border.all(color: Colors.blue[800]!, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      booth.id,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (booth.status == 'available')
                                      Text(
                                        'RM${booth.price.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showBoothDetailsModal(BuildContext context, Booth booth) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booth ${booth.id}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                '${booth.type} Booth',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: booth.status == 'available' ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booth.status.toUpperCase(),
                      style: TextStyle(
                        color: booth.status == 'available' ? Colors.green[800] : Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Price', style: TextStyle(color: Colors.grey[600])),
                      Text(
                        'RM${booth.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Dimensions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(booth.dimensions, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              const Text('Included Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...booth.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(feature),
                  ],
                ),
              )),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}