import 'dart:io' as io;
import 'dart:convert'; // Required for base64
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/db_service.dart';

class AdminFloorplanScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const AdminFloorplanScreen({super.key, required this.eventId, required this.eventName});

  @override
  State<AdminFloorplanScreen> createState() => _AdminFloorplanScreenState();
}

class _AdminFloorplanScreenState extends State<AdminFloorplanScreen> {
  final DbService _dbService = DbService();
  String? _imageUrl; // Holds the Base64 string data
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingMap();
  }

  Future<void> _loadExistingMap() async {
    try {
      // Pulls from 'global' configuration
      final dynamic data = await _dbService.getFloorplanLayout('global');
      
      if (data != null && data is List && data.isNotEmpty && data[0] is Map) {
        final firstItem = data[0] as Map;
        if (firstItem.containsKey('imageUrl')) {
          setState(() => _imageUrl = firstItem['imageUrl']);
        }
      }
    } catch (e) {
      debugPrint("Error loading map: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadMap() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50, // Helps stay under Firestore's 1MB document limit
      maxWidth: 800,    // Force resize width to max 800px
      maxHeight: 800,   // Force resize height to max 800px
    );

    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      // DbService converts the file to Base64 and saves to Firestore
      await _dbService.saveFloorplanLayout(widget.eventId, image);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Global Floor Plan saved! Applies to all events.")),
        );
        _loadExistingMap(); 
      }
    } catch (e) {
      debugPrint("Save Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload Failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Global Floor Plan"), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Note: Images are saved as text in Firestore. Use small files.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: _buildImage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _uploadMap,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Select & Upload Map (PNG/JPG)"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImage() {
    if (_imageUrl == null || _imageUrl!.isEmpty) {
      return const Center(child: Text("No Map Available"));
    }

    // Displays the Base64 image data stored in Firestore
    if (_imageUrl!.startsWith('data:image')) {
      try {
        final base64String = _imageUrl!.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.contain,
        );
      } catch (e) {
        return const Center(child: Icon(Icons.broken_image, color: Colors.red));
      }
    }

    // Fallback for network or file paths
    return kIsWeb || _imageUrl!.startsWith('http')
        ? Image.network(_imageUrl!, fit: BoxFit.contain)
        : Image.file(io.File(_imageUrl!), fit: BoxFit.contain);
  }
}