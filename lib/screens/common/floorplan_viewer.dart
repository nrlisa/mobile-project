import 'package:flutter/material.dart';
import '../../services/db_service.dart';
import '../admin/admin_floorplan.dart'; // To reuse the Painter and Models

class FloorplanViewerScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const FloorplanViewerScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<FloorplanViewerScreen> createState() => _FloorplanViewerScreenState();
}

class _FloorplanViewerScreenState extends State<FloorplanViewerScreen> {
  final DbService _dbService = DbService();
  List<PlacedBooth> _booths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final result = await _dbService.getFloorplanLayout(widget.eventId);
    if (mounted) {
      setState(() {
        _booths = (result).map((json) => PlacedBooth.fromJson(json)).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View: ${widget.eventName}")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Stack(
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 900),
                painter: HallGridPainter(gridSize: 20.0),
              ),
              ..._booths.map((booth) => Positioned(
                left: booth.x,
                top: booth.y,
                child: Container(
                  width: booth.width,
                  height: booth.height,
                  color: Color(booth.colorValue).withValues(alpha: 0.8),
                  child: Center(child: Text(booth.label)),
                ),
              )),
            ],
          ),
    );
  }
}