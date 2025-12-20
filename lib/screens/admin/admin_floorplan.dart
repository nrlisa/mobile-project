import 'package:flutter/material.dart';
import '../../services/db_service.dart';

class AdminFloorplanScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const AdminFloorplanScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<AdminFloorplanScreen> createState() => _AdminFloorplanScreenState();
}

class _AdminFloorplanScreenState extends State<AdminFloorplanScreen> {
  final double _gridSize = 20.0;
  List<PlacedBooth> _booths = [];
  bool _isLoading = true;
  final DbService _dbService = DbService();

  @override
  void initState() {
    super.initState();
    _loadFloorplan();
  }

  // --- SAFE LOAD FUNCTION ---
  Future<void> _loadFloorplan() async {
    try {
      debugPrint("--- LOADING FLOORPLAN FOR: ${widget.eventId} ---");
      
      // 1. Fetch Data safely
      final dynamic result = await _dbService.getFloorplanLayout(widget.eventId);
      debugPrint("Raw DB Result: $result"); // CHECK YOUR CONSOLE FOR THIS

      if (!mounted) return;

      // 2. Handle NULL result (Database returned nothing)
      if (result == null) {
        debugPrint("Result is NULL. Using empty list.");
        setState(() {
          _booths = [];
          _isLoading = false;
        });
        return;
      }

      // 3. Handle NON-LIST result (Database returned an error object or single map)
      if (result is! List) {
        debugPrint("Result is NOT a List. It is: ${result.runtimeType}. Using empty list.");
        setState(() {
          _booths = [];
          _isLoading = false;
        });
        return;
      }

      // 4. Safe Parsing Loop
      final List<PlacedBooth> safeBooths = [];
      for (var item in result) {
        if (item == null) continue; // Skip null items

        try {
          // Force convert to Map<String, dynamic>
          final Map<String, dynamic> map = Map<String, dynamic>.from(item as Map);
          safeBooths.add(PlacedBooth.fromJson(map));
        } catch (e) {
          debugPrint("Skipping bad booth item: $e");
        }
      }

      debugPrint("Successfully loaded ${safeBooths.length} booths.");
      setState(() {
        _booths = safeBooths;
        _isLoading = false;
      });

    } catch (e) {
      debugPrint('CRITICAL ERROR loading floorplan: $e');
      if (mounted) {
        // Don't leave the spinner spinning forever on error
        setState(() {
          _booths = []; 
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveFloorplan() async {
    try {
      final List<Map<String, dynamic>> layoutList = _booths.map((b) => b.toJson()).toList();
      await _dbService.saveFloorplanLayout(widget.eventId, layoutList);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Layout saved for ${widget.eventName}!")),
      );
    } catch (e) {
      debugPrint("Save Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving: $e"))
        );
      }
    }
  }

  double _snapToGrid(double value) {
    return (value / _gridSize).round() * _gridSize;
  }

  void _addBooth(BoothTemplate template, Offset dropPosition, BuildContext context) {
    // Safety check for context
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return;

    final RenderBox renderBox = renderObject;
    final Offset localPos = renderBox.globalToLocal(dropPosition);

    setState(() {
      _booths.add(PlacedBooth(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        x: _snapToGrid(localPos.dx - (template.width / 2)),
        y: _snapToGrid(localPos.dy - (template.height / 2)),
        width: template.width,
        height: template.height,
        label: template.label,
        colorValue: template.color.toARGB32(), // Safe int conversion
      ));
    });
  }

  void _deleteBooth(String id) {
    setState(() {
      _booths.removeWhere((b) => b.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Layout: ${widget.eventName}"),
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
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return DragTarget<BoothTemplate>(
                          onWillAcceptWithDetails: (data) => true,
                          onAcceptWithDetails: (details) {
                            _addBooth(details.data, details.offset, context);
                          },
                          builder: (context, candidateData, rejectedData) {
                            return SingleChildScrollView(
                              child: SizedBox(
                                height: 900,
                                width: constraints.maxWidth,
                                child: Stack(
                                  children: [
                                    CustomPaint(
                                      size: Size(constraints.maxWidth, 900),
                                      painter: HallGridPainter(gridSize: _gridSize),
                                    ),
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
                                              setState(() {
                                                booth.x = _snapToGrid(booth.x);
                                                booth.y = _snapToGrid(booth.y);
                                              });
                                            },
                                            onDoubleTap: () => _deleteBooth(booth.id),
                                            child: _buildBoothWidget(booth),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  height: 140,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, -2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Drag to add booth:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDraggableItem(BoothTemplate(
                              60, 60, "Standard", Colors.blue, "3x3m")),
                          _buildDraggableItem(BoothTemplate(
                              100, 60, "Premium", Colors.orange, "5x3m")),
                          _buildDraggableItem(BoothTemplate(
                              120, 100, "VIP", Colors.purple, "6x5m")),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBoothWidget(PlacedBooth booth) {
    return Container(
      width: booth.width,
      height: booth.height,
      decoration: BoxDecoration(
        // SAFE FIX: Changed back to withOpacity for compatibility
        color: Color(booth.colorValue).withValues(alpha: 0.9),
        border: Border.all(color: Colors.black87, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(booth.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10)),
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
          alignment: Alignment.center,
          child: Text(template.label,
              style: const TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 10)),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 30,
            decoration: BoxDecoration(
                color: template.color, borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 5),
          Text(template.label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(template.sizeDesc,
              style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}

class HallGridPainter extends CustomPainter {
  final double gridSize;
  HallGridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;
    final dividerPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2.0;

  // 1. Draw Grid
    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // 2. Draw Hall Dividers (Fixed 300px height per hall)
    double hallHeight = 300.0;
    
    canvas.drawLine(Offset(0, hallHeight), Offset(size.width, hallHeight), dividerPaint);
    canvas.drawLine(Offset(0, hallHeight * 2), Offset(size.width, hallHeight * 2), dividerPaint);

    // 3. Draw Centered Labels
    // We pass the CENTER X (size.width / 2) and CENTER Y for each hall
    _drawCenteredText(canvas, "HALL A", size.width / 2, hallHeight / 2);
    _drawCenteredText(canvas, "HALL B", size.width / 2, hallHeight + (hallHeight / 2));
    _drawCenteredText(canvas, "HALL C", size.width / 2, (hallHeight * 2) + (hallHeight / 2));
  }

  void _drawCenteredText(Canvas canvas, String text, double cx, double cy) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
          color: Colors.grey.shade300, // Lighter color acts better as watermark
          fontSize: 40,                // Larger font for visibility
          fontWeight: FontWeight.bold),
    );
    
    final textPainter = TextPainter(
      text: textSpan, 
      textDirection: TextDirection.ltr
    );
    
    textPainter.layout(); // Measures the text size

    // Calculate position so the text is exactly centered on (cx, cy)
    final offset = Offset(
      cx - (textPainter.width / 2), 
      cy - (textPainter.height / 2)
    );
    
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
  

class BoothTemplate {
  final double width;
  final double height;
  final String label;
  final Color color;
  final String sizeDesc;
  BoothTemplate(this.width, this.height, this.label, this.color, this.sizeDesc);
}

// --- SAFE DATA MODEL ---
class PlacedBooth {
  String id;
  double x, y, width, height;
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
        'colorValue': colorValue
      };

  factory PlacedBooth.fromJson(Map<String, dynamic> json) {
    return PlacedBooth(
      // Fallback ID if null
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      // Handle nulls and convert numbers safely (int -> double)
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 60).toDouble(),
      height: (json['height'] ?? 60).toDouble(),
      label: json['label']?.toString() ?? "Booth",
      colorValue: (json['colorValue'] ?? 0xFF2196F3).toInt(),
    );
  }
}