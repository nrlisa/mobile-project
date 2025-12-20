import 'package:flutter/material.dart';
import '../../services/db_service.dart';

class FloorplanViewer extends StatelessWidget {
  final String eventId;

  const FloorplanViewer({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final DbService dbService = DbService();

    return Scaffold(
      appBar: AppBar(title: const Text("Event Floor Plan")),
      body: FutureBuilder<List<dynamic>>(
        // Fetch the layout which now contains the static image URL [Inference]
        future: dbService.getFloorplanLayout(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final layout = snapshot.data ?? [];
          
          // Check if an image URL exists in the layout list [Inference]
          String? imageUrl;
          if (layout.isNotEmpty && layout[0] is Map) {
            imageUrl = layout[0]['imageUrl'];
          }

          if (imageUrl == null || imageUrl.isEmpty) {
            return const Center(
              child: Text("No floor plan image has been uploaded for this event."),
            );
          }

          return Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}