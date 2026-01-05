import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/event_model.dart';
import '../../models/booth.dart';
import '../../services/db_service.dart';
import 'admin_floor_plan_widget.dart';

class AdminEventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const AdminEventDetailsScreen({super.key, required this.event});

  @override
  State<AdminEventDetailsScreen> createState() => _AdminEventDetailsScreenState();
}

class _AdminEventDetailsScreenState extends State<AdminEventDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DbService _dbService = DbService();
  
  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late bool _isPublished;
  bool _competitorCheckEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _nameController = TextEditingController(text: widget.event.name);
    _locationController = TextEditingController(text: widget.event.location);
    _isPublished = widget.event.isPublished;
    _loadEventSettings();
  }

  Future<void> _loadEventSettings() async {
    try {
      final data = await _dbService.getEventData(widget.event.id);
      if (mounted) {
        setState(() {
          _competitorCheckEnabled = data['competitorCheckEnabled'] ?? false;
        });
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Settings'),
            Tab(text: 'Booths'),
            Tab(text: 'Floor Plan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSettingsTab(),
          _buildBoothsTab(),
          _buildFloorPlanTab(),
        ],
      ),
    );
  }

  // --- 1. SETTINGS TAB (Exhibition Management) ---
  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Event Name')),
          TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
          SwitchListTile(
            title: const Text("Published"),
            subtitle: const Text("Visible to exhibitors"),
            value: _isPublished,
            onChanged: (val) => setState(() => _isPublished = val),
          ),
          SwitchListTile(
            title: const Text("Competitor Adjacency Rule"),
            subtitle: const Text("Prevent competitors from booking adjacent booths"),
            value: _competitorCheckEnabled,
            onChanged: (val) => setState(() => _competitorCheckEnabled = val),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _dbService.updateEvent(widget.event.id, {
                'name': _nameController.text,
                'location': _locationController.text,
                'isPublished': _isPublished,
                'competitorCheckEnabled': _competitorCheckEnabled,
              });
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event Updated")));
            },
            child: const Text("Save Changes"),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _confirmDeleteEvent(),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete Event"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEvent() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text("Are you sure? This will delete all booths and applications."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _dbService.deleteEvent(widget.event.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // --- 2. BOOTHS TAB (Booth Management) ---
  Widget _buildBoothsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBoothsDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Booth>>(
        stream: _dbService.getBoothsStream(widget.event.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final booths = snapshot.data!;
          
          if (booths.isEmpty) return const Center(child: Text("No booths created yet."));

          return ListView.builder(
            itemCount: booths.length,
            itemBuilder: (context, index) {
              final booth = booths[index];
              return ListTile(
                title: Text("Booth ${booth.boothNumber} (${booth.size})"),
                subtitle: Text("RM ${booth.price} - ${booth.status}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditBoothDialog(booth);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditBoothDialog(Booth booth) {
    final priceController = TextEditingController(text: booth.price.toString());
    final sizeController = TextEditingController(text: booth.size);
    final categoryController = TextEditingController(text: booth.companyCategory ?? '');
    String status = booth.status;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit Booth ${booth.boothNumber}"),
        content: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: sizeController, decoration: const InputDecoration(labelText: "Size")),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              initialValue: status,
              items: ['available', 'booked', 'reserved', 'maintenance']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                  .toList(),
              onChanged: (val) => status = val!,
              decoration: const InputDecoration(labelText: "Status"),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: "Company Category (for Adjacency Rule)"),
            ),
          ],
        ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _dbService.updateBoothDetails(widget.event.id, booth.id, {
                'size': sizeController.text,
                'price': double.tryParse(priceController.text) ?? booth.price,
                'status': status,
                'companyCategory': categoryController.text.isEmpty ? null : categoryController.text,
              });
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showAddBoothsDialog() {
    final sizeController = TextEditingController(text: "Standard");
    final priceController = TextEditingController(text: "100");
    final countController = TextEditingController(text: "10");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Generate Booths"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: sizeController, decoration: const InputDecoration(labelText: "Size (e.g. Standard)")),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: countController, decoration: const InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _dbService.createBoothsBatch(
                widget.event.id, 
                sizeController.text, 
                double.tryParse(priceController.text) ?? 0.0, 
                int.tryParse(countController.text) ?? 0
              );
              Navigator.pop(ctx);
            },
            child: const Text("Generate"),
          ),
        ],
      ),
    );
  }

  // --- 3. FLOOR PLAN TAB (Floor Plan Management) ---
  Widget _buildFloorPlanTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('events').doc(widget.event.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final eventData = snapshot.data!.data() as Map<String, dynamic>?;
        final floorPlanUrl = eventData?['floorPlanUrl'] as String?;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text("Upload/Change Floor Plan Image"),
                onPressed: _pickAndUploadImage,
              ),
            ),
            Expanded(
              child: floorPlanUrl == null || floorPlanUrl.isEmpty
                  ? const Center(child: Text("Please upload a floor plan image first."))
                  : AdminFloorPlanWidget(
                      eventId: widget.event.id,
                      floorPlanUrl: floorPlanUrl,
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _dbService.uploadEventFloorPlan(widget.event.id, image);
    }
  }
}