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
      final dynamic globalData = await _dbService.getFloorplanLayout('global');
      if (globalData != null && globalData is List && globalData.isNotEmpty) {
        final firstItem = globalData[0];
        if (firstItem is Map && firstItem.containsKey('imageUrl')) {
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
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? (imageUrl.startsWith('data:') || !imageUrl.startsWith('http')
                        ? _buildBase64Image(imageUrl)
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => _buildError(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              );
                            },
                          ))
                    : const Center(
                        child: Text("No floorplan image found", style: TextStyle(color: Colors.white54)),
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

  Widget _buildBase64Image(String base64String) {
    try {
      // Robustly handle data URI format
      String data = base64String.contains(',') 
          ? base64String.split(',').last 
          : base64String;
      data = data.replaceAll(RegExp(r'\s+'), ''); // Remove newlines/spaces
      // Normalize URL-safe base64 to standard base64 (fixes Web vs Mobile differences)
      data = data.replaceAll('-', '+').replaceAll('_', '/');
          
      // Fix Base64 padding if missing (Crucial for some image sources)
      int mod = data.length % 4;
      if (mod > 0) {
        data += '=' * (4 - mod);
      }

      debugPrint("DEBUG: Final Base64 Data Length: ${data.length}");

      return Image.memory(
        base64Decode(data),
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _buildError(),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
      );
    } catch (e) {
      debugPrint("DEBUG: Base64 Error: $e");
      return _buildError();
    }
  }

  Widget _buildError() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, color: Colors.white54, size: 50),
          SizedBox(height: 10),
          Text("Floorplan not available", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}