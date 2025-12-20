import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/db_service.dart';
import '../../utils/app_theme.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  // Simplified layout state to store the image URL [Inference]
  String? _imageUrl;
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
    
    // Fetch the layout data from Firestore
    final List<dynamic> data = await DbService().getFloorplanLayout(widget.eventId);
    
    if (mounted) {
      setState(() {
        // Look for the 'imageUrl' in the first element of the layout list [Inference]
        if (data.isNotEmpty && data[0] is Map) {
          _imageUrl = data[0]['imageUrl'];
        }
        _isLoading = false;
      });
    }
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
                  Text("Exhibition Map", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
                  SizedBox(height: 10),
                  Text("View the floor plan below. Log in to book a booth."),
                ],
              ),
            ),
            
            // --- SIMPLIFIED MAP CONTAINER ---
            Container(
              height: 500, 
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_imageUrl == null || _imageUrl!.isEmpty)
                      ? const Center(child: Text("No floor plan available."))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: InteractiveViewer(
                            boundaryMargin: const EdgeInsets.all(20.0),
                            minScale: 0.5,
                            maxScale: 3.0,
                            child: Image.network(
                              _imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
            ),
            
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Login to Book", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}