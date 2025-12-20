import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/db_service.dart';
import '../../utils/app_theme.dart';
import '../admin/admin_floorplan.dart'; // Import to use PlacedBooth and HallGridPainter

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  List<PlacedBooth> _booths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLayout();
  }

  Future<void> _fetchLayout() async {
    if (widget.eventId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    final data = await DbService().getFloorplanLayout(widget.eventId);
    setState(() {
      _booths = data.map((json) => PlacedBooth.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Exhibition Map", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
                  SizedBox(height: 10),
                  Text("Scroll to view Hall A, B, and C. Log in to book."),
                ],
              ),
            ),
            
            // --- MAP CONTAINER ---
            Container(
              height: 500, // Fixed height for viewing
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _booths.isEmpty
                      ? const Center(child: Text("No floor plan available."))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: InteractiveViewer(
                            boundaryMargin: const EdgeInsets.all(20.0),
                            minScale: 0.5,
                            maxScale: 3.0,
                            // Ensure the content size matches the Admin size (900 height)
                            constrained: false, 
                            child: SizedBox(
                              width: 800, // Fixed large width
                              height: 900, // Fixed large height matching Admin
                              child: Stack(
                                children: [
                                  // Background Hall A/B/C
                                  CustomPaint(
                                    size: const Size(800, 900),
                                    painter: HallGridPainter(gridSize: 20),
                                  ),
                                  
                                  // Booths
                                  ..._booths.map((booth) => Positioned(
                                    left: booth.x,
                                    top: booth.y,
                                    child: Container(
                                      width: booth.width,
                                      height: booth.height,
                                      decoration: BoxDecoration(
                                        color: Color(booth.colorValue).withValues(alpha: 0.9),
                                        border: Border.all(color: Colors.black54),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        booth.label,
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
            
            // Login Buttons...
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                child: const Text("Login to Book", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}