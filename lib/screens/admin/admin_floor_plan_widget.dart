import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/booth.dart';
import '../../services/db_service.dart';

class AdminFloorPlanWidget extends StatefulWidget {
  final String eventId;
  final String floorPlanUrl;

  const AdminFloorPlanWidget({
    super.key,
    required this.eventId,
    required this.floorPlanUrl,
  });

  @override
  State<AdminFloorPlanWidget> createState() => _AdminFloorPlanWidgetState();
}

class _AdminFloorPlanWidgetState extends State<AdminFloorPlanWidget> {
  final DbService _dbService = DbService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Booth>>(
      stream: _dbService.getBoothsStream(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final booths = snapshot.data!;
        // Sort booths to ensure consistent rendering order
        booths.sort((a, b) {
          int extractNumber(String s) {
            final match = RegExp(r'(\d+)').firstMatch(s);
            return match != null ? int.parse(match.group(0)!) : 0;
          }
          int numA = extractNumber(a.boothNumber);
          int numB = extractNumber(b.boothNumber);
          if (numA != numB) return numA.compareTo(numB);
          return a.boothNumber.compareTo(b.boothNumber);
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Floor Plan Image
                Positioned.fill(
                  child: _buildImage(),
                ),

                // Draggable Booths
                ...booths.map((booth) {
                  return _DraggableBoothItem(
                    key: ValueKey(booth.id),
                    booth: booth,
                    parentSize: Size(constraints.maxWidth, constraints.maxHeight),
                    onPositionChanged: (newX, newY) {
                      _updateBoothPosition(booth, newX, newY);
                    },
                    onTap: () {
                      _showEditBoothDialog(booth);
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildImage() {
    if (widget.floorPlanUrl.startsWith('data:image')) {
      try {
        final base64String = widget.floorPlanUrl.split(',').last.replaceAll(RegExp(r'\s+'), '');
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.fill,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
        );
      } catch (e) {
        return const Center(child: Icon(Icons.error));
      }
    }
    return Image.network(
      widget.floorPlanUrl,
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image, size: 50)),
      ),
    );
  }

  void _updateBoothPosition(Booth booth, double x, double y) {
    // Updates Firestore with normalized coordinates (0.0 to 1.0)
    _dbService.updateBoothCoordinates(
      widget.eventId,
      booth.id,
      x,
      y,
      booth.width ?? 0.1, // Default width 10% if not set
      booth.height ?? 0.08, // Default height 8% if not set
    ).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booth ${booth.boothNumber} saved"), duration: const Duration(milliseconds: 500)),
        );
      }
    });
  }

  void _showEditBoothDialog(Booth booth) {
    final idController = TextEditingController(text: booth.boothNumber);
    final sizeController = TextEditingController(text: booth.size);
    final priceController = TextEditingController(text: booth.price.toString());
    final categoryController = TextEditingController(text: booth.companyCategory ?? '');
    String selectedStatus = booth.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
        title: Text("Edit Booth ${booth.boothNumber}"),
        content: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: "Booth ID/Number"),
            ),
            TextField(
              controller: sizeController,
              decoration: const InputDecoration(labelText: "Type/Size (Small, Medium, Large)"),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price (RM)"),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              decoration: const InputDecoration(labelText: "Status"),
              items: ['available', 'booked', 'reserved', 'maintenance']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => selectedStatus = val!),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: "Company Category"),
            ),
          ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _dbService.updateBoothDetails(widget.eventId, booth.id, {
                'boothNumber': idController.text,
                'size': sizeController.text,
                'price': double.tryParse(priceController.text) ?? booth.price,
                'status': selectedStatus,
                'companyCategory': categoryController.text.isEmpty ? null : categoryController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
      ),
    );
  }
}

class _DraggableBoothItem extends StatefulWidget {
  final Booth booth;
  final Size parentSize;
  final Function(double, double) onPositionChanged;
  final VoidCallback onTap;

  const _DraggableBoothItem({
    super.key,
    required this.booth,
    required this.parentSize,
    required this.onPositionChanged,
    required this.onTap,
  });

  @override
  State<_DraggableBoothItem> createState() => _DraggableBoothItemState();
}

class _DraggableBoothItemState extends State<_DraggableBoothItem> {
  Offset position = Offset.zero;

  @override
  void initState() {
    super.initState();
    _updatePositionFromBooth();
  }

  @override
  void didUpdateWidget(_DraggableBoothItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-sync position if parent resizes or DB updates (unless currently dragging logic is added)
    if (oldWidget.parentSize != widget.parentSize ||
        oldWidget.booth.x != widget.booth.x ||
        oldWidget.booth.y != widget.booth.y) {
      _updatePositionFromBooth();
    }
  }

  void _updatePositionFromBooth() {
    double x = (widget.booth.x ?? 0.0) * widget.parentSize.width;
    double y = (widget.booth.y ?? 0.0) * widget.parentSize.height;
    position = Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    double width = (widget.booth.width ?? 0.1) * widget.parentSize.width;
    double height = (widget.booth.height ?? 0.08) * widget.parentSize.height;

    return Positioned(
      left: position.dx,
      top: position.dy,
      width: width,
      height: height,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            double newX = position.dx + details.delta.dx;
            double newY = position.dy + details.delta.dy;

            // Clamp to map bounds
            newX = newX.clamp(0.0, widget.parentSize.width - width);
            newY = newY.clamp(0.0, widget.parentSize.height - height);

            position = Offset(newX, newY);
          });
        },
        onPanEnd: (details) {
          // Calculate normalized position (0.0 - 1.0)
          double relX = position.dx / widget.parentSize.width;
          double relY = position.dy / widget.parentSize.height;
          widget.onPositionChanged(relX, relY);
        },
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _getBoothColor(widget.booth.status).withValues(alpha: 0.85),
            border: Border.all(color: Colors.white, width: 1.5),
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))
            ],
          ),
          child: Center(
            child: Text(
              widget.booth.boothNumber,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Color _getBoothColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'booked':
        return Colors.red;
      case 'selected':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}