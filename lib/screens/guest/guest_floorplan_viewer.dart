import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/db_service.dart';

class GuestFloorplanViewer extends StatefulWidget {
  final String eventId;
  final String eventName;

  const GuestFloorplanViewer({
    super.key, 
    required this.eventId, 
    required this.eventName
  });

  @override
  State<GuestFloorplanViewer> createState() => _GuestFloorplanViewerState();
}

class _GuestFloorplanViewerState extends State<GuestFloorplanViewer> {
  final DbService _dbService = DbService();
  late Future<String?> _floorPlanFuture;

  @override
  void initState() {
    super.initState();
    _floorPlanFuture = _loadFloorPlan();
  }

  Future<String?> _loadFloorPlan() async {
    try {
      // Load the global layout (applies to all events)
      debugPrint("DEBUG: Attempting to fetch global floorplan...");
      final dynamic globalData = await _dbService.getFloorplanLayout('global');
      if (globalData != null && globalData is List && globalData.isNotEmpty) {
        final firstItem = globalData[0];
        if (firstItem is Map && firstItem.containsKey('imageUrl')) {
          debugPrint("DEBUG: Found global floorplan image.");
          return firstItem['imageUrl'].toString();
        }
      }

      // 2. Fallback: Try Event Specific Layout (Legacy support or if global fails)
      final eventData = await _dbService.getEventData(widget.eventId);
      if (eventData.containsKey('floorPlanUrl') && eventData['floorPlanUrl'] != null) {
        final url = eventData['floorPlanUrl'].toString();
        if (url.isNotEmpty) return url;
      }
    } catch (e) {
      debugPrint("Error loading floorplan: $e");
    }
    debugPrint("DEBUG: No floorplan found in Global or Event data.");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<String?>(
        future: _floorPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          
          final imageUrl = snapshot.data;
          
          // DEBUGGING: Print raw data to console
          debugPrint("DEBUG: EventID: ${widget.eventId}");
          if (imageUrl != null) {
            debugPrint("DEBUG: Raw URL Length: ${imageUrl.length}");
            debugPrint("DEBUG: Start of URL: ${imageUrl.substring(0, imageUrl.length > 100 ? 100 : imageUrl.length)}");
          } else {
            debugPrint("DEBUG: Image URL is NULL");
          }
          
          return Stack(
            children: [
              // Interactive Image Viewer
              Container(
                color: Colors.grey[200], // Changed to light grey for better contrast
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: _buildImage(imageUrl),
                  ),
                ),
              ),

              // Back Button with Safe Navigation
              Positioned(
                top: 40,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/guest');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                ),
              ),

              // Event Name Title
              Positioned(
                top: 48,
                left: 70,
                right: 20,
                child: Text(
                  widget.eventName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(
        child: Text("No floorplan image found", style: TextStyle(color: Colors.black54)),
      );
    }

    if (imageUrl.startsWith('data:image')) {
      try {
        // Clean the string to remove any newlines or whitespace that might break decoding
        final base64String = imageUrl.split(',').last.replaceAll(RegExp(r'\s+'), '');
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => _buildError(),
        );
      } catch (e) {
        debugPrint("Base64 decoding error: $e");
        return _buildError();
      }
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildError(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(color: Colors.black));
      },
    );
  }

  Widget _buildError() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, color: Colors.grey, size: 50),
          SizedBox(height: 10),
          Text("Floorplan not available", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}