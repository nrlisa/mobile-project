import 'dart:convert'; // Required for base64Decode
import 'package:flutter/material.dart';
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
  String? _imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  Future<void> _loadMap() async {
    try {
      // Pull from 'global' to ensure all events show the same map
      final dynamic data = await _dbService.getFloorplanLayout('global');
      
      if (data is List && data.isNotEmpty) {
        final firstItem = data[0];
        if (firstItem is Map && firstItem.containsKey('imageUrl')) {
          setState(() => _imageUrl = firstItem['imageUrl']);
        }
      }
    } catch (e) {
      debugPrint("Error loading guest floorplan: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Floor Plan: ${widget.eventName}"),
        backgroundColor: Colors.blueAccent, 
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: InteractiveViewer( 
                minScale: 0.5,
                maxScale: 4.0,
                child: _buildImage(),
              ),
            ),
    );
  }

  Widget _buildImage() {
    if (_imageUrl == null || _imageUrl!.isEmpty) {
      return const Center(
        child: Text("No Map Available", style: TextStyle(color: Colors.grey, fontSize: 18)),
      );
    }

    // Logic: Handle Base64 strings directly from Firestore
    if (_imageUrl!.startsWith('data:image')) {
      try {
        final base64String = _imageUrl!.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.contain,
        );
      } catch (e) {
        return const Icon(Icons.broken_image, size: 50, color: Colors.red);
      }
    }

    // Fallback for network links
    return Image.network(
      _imageUrl!,
      fit: BoxFit.contain,
      errorBuilder: (context, e, s) => const Icon(Icons.broken_image, size: 50),
    );
  }
}