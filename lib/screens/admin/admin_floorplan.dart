import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminFloorplanScreen extends StatefulWidget {
  const AdminFloorplanScreen({super.key});

  @override
  State<AdminFloorplanScreen> createState() => _AdminFloorplanScreenState();
}

class _AdminFloorplanScreenState extends State<AdminFloorplanScreen> {
  final double _gridSize = 20.0;
  List<PlacedBooth> _booths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFloorplan();
  }

  // --- Persistence Logic ---

  Future<void> _loadFloorplan() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('floorplan_booths');
    
    if (storedData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(storedData);
        setState(() {
          _booths = decoded.map((json) => PlacedBooth.fromJson(json)).toList();
        });
      } catch (e) {
        debugPrint('Error loading floorplan: $e');
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveFloorplan() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_booths.map((b) => b.toJson()).toList());
    await prefs.setString('floorplan_booths', encoded);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Floorplan saved successfully!")),
      );
    }
  }

  // --- Grid Helpers ---

  double _snapToGrid(double value) {
    return (value / _gridSize).round() * _gridSize;
  }

  void _addBooth(BoothTemplate template, Offset dropPosition, BuildContext context) {
    // Convert global drop position to local coordinates relative to the grid
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPos = renderBox.globalToLocal(dropPosition);

    // Center the item on the mouse/finger
    final double adjustedX = localPos.dx - (template.width / 2);
    final double adjustedY = localPos.dy - (template.height / 2);

    setState(() {
      _booths.add(PlacedBooth(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
        x: _snapToGrid(adjustedX),
        y: _snapToGrid(adjustedY),
        width: template.width,
        height: template.height,
        label: template.label,
        // ignore: deprecated_member_use
        colorValue: template.color.value,
      ));
    });
  }


  void _deleteBooth(String id) {
    setState(() {
      _booths.removeWhere((b) => b.id == id);
    });
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Floorplan Editor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFloorplan,
            tooltip: 'Save Layout',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. The Interactive Grid Area
                Expanded(
                  child: Container(
                    color: Colors.grey.shade100,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return DragTarget<BoothTemplate>(
                          onWillAcceptWithDetails: (data) => true,
                          onAcceptWithDetails: (details) {
                            _addBooth(details.data, details.offset, context);
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Stack(
                              children: [
                                // Grid Background
                                CustomPaint(
                                  size: Size(constraints.maxWidth, constraints.maxHeight),
                                  painter: GridPainter(gridSize: _gridSize),
                                ),
                                // Placed Booths
                                ..._booths.map((booth) => Positioned(
                                      left: booth.x,
                                      top: booth.y,
                                      child: GestureDetector(
                                        onPanUpdate: (details) {
                                          setState(() {
                                            booth.x += details.delta.dx;
                                            booth.y += details.delta.dy;
                                          });
                                        },
                                        onPanEnd: (details) {
                                          // Snap on release
                                          setState(() {
                                            booth.x = _snapToGrid(booth.x);
                                            booth.y = _snapToGrid(booth.y);
                                          });
                                        },
                                        onDoubleTap: () => _deleteBooth(booth.id),
                                        child: Container(
                                          width: booth.width,
                                          height: booth.height,
                                          decoration: BoxDecoration(
                                            color: Color(booth.colorValue),
                                            border: Border.all(color: Colors.black54),
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.2),
                                                blurRadius: 4,
                                                offset: const Offset(2, 2),
                                              )
                                            ],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            booth.label,
                                            style: const TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    )),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // 2. The Draggable Palette
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Drag booths to the grid:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDraggableItem(BoothTemplate(60, 60, "Standard", Colors.blue)),
                          _buildDraggableItem(BoothTemplate(100, 60, "Double", Colors.orange)),
                          _buildDraggableItem(BoothTemplate(120, 120, "Island", Colors.purple)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDraggableItem(BoothTemplate template) {
    return Draggable<BoothTemplate>(
      data: template,
      feedback: Opacity(
        opacity: 0.7,
        child: Container(
          width: template.width,
          height: template.height,
          color: template.color,
          child: Center(
              child: Text(template.label,
                  style: const TextStyle(color: Colors.white, decoration: TextDecoration.none, fontSize: 10))),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: template.color, borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.store, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(template.label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

// --- Helper Classes ---

class GridPainter extends CustomPainter {
  final double gridSize;
  GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data class for the Drag Source
class BoothTemplate {
  final double width;
  final double height;
  final String label;
  final Color color;

  BoothTemplate(this.width, this.height, this.label, this.color);
}

// Data class for Saved State (Serializable)
class PlacedBooth {
  String id;
  double x;
  double y;
  double width;
  double height;
  String label;
  int colorValue;

  PlacedBooth({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.label,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'label': label,
        'colorValue': colorValue,
      };

  factory PlacedBooth.fromJson(Map<String, dynamic> json) => PlacedBooth(
        id: json['id'],
        x: json['x'],
        y: json['y'],
        width: json['width'],
        height: json['height'],
        label: json['label'],
        colorValue: json['colorValue'],
      );
}