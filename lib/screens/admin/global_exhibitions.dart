import 'package:flutter/material.dart';
import '../../services/db_service.dart';
import 'admin_floorplan.dart';
import '../../models/booth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalExhibitionsScreen extends StatefulWidget {
  const GlobalExhibitionsScreen({super.key});

  @override
  State<GlobalExhibitionsScreen> createState() => _GlobalExhibitionsScreenState();
}

class _GlobalExhibitionsScreenState extends State<GlobalExhibitionsScreen> {
  final DbService _dbService = DbService();

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Global Exhibitions")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEventDialog(context),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbService.getEvents(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(child: Text("No exhibitions found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final String eventId = event['id'] ?? "";
              final String eventName = event['name'] ?? "Unnamed Exhibition";
              final String location = event['location'] ?? "No Location";
              final bool isPublished = event['isPublished'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("$location\nStatus: ${isPublished ? 'Published' : 'Draft'}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // EDIT BUTTON: Metadata
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit Details',
                        onPressed: () => _showEditEventDialog(context, eventId, event),
                      ),
                      // MAP BUTTON: Floorplan
                      IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        tooltip: 'Edit Floorplan',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminFloorplanScreen(
                              eventId: eventId,
                              eventName: eventName,
                            ),
                          ),
                        ),
                      ),
                      // BOOTH MANAGEMENT BUTTON
                      IconButton(
                        icon: const Icon(Icons.store, color: Colors.green),
                        tooltip: 'Manage Booths',
                        onPressed: () => _showManageBoothsDialog(context, eventId, eventName),
                      ),
                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Exhibition',
                        onPressed: () => _confirmDelete(context, eventId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Dialog to Manage Booths (Create types, set prices)
  void _showManageBoothsDialog(BuildContext context, String eventId, String eventName) {
    final quantityController = TextEditingController(text: '10');
    final priceController = TextEditingController(text: '100.0');
    String selectedSize = 'Small';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Manage Booths: $eventName"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Generate New Booths", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSize,
                    decoration: const InputDecoration(labelText: "Booth Type/Size"),
                    items: ['Small', 'Medium', 'Large']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => selectedSize = val!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Price (RM)"),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: "Quantity to Add"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final int? qty = int.tryParse(quantityController.text);
                        final double? price = double.tryParse(priceController.text);

                        if (qty != null && price != null && qty > 0) {
                          try {
                            await _dbService.createBoothsBatch(eventId, selectedSize, price, qty);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Added $qty $selectedSize booths."))
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
                              );
                            }
                          }
                        }
                      },
                      child: const Text("Generate"),
                    ),
                  ),
                  const Divider(height: 30, thickness: 2),
                  const Text("Inventory Summary", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  StreamBuilder<List<Booth>>(
                    stream: _dbService.getBoothsStream(eventId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final booths = snapshot.data ?? [];
                      if (booths.isEmpty) return const Text("No booths created yet.");

                      // Aggregation Logic
                      final Map<String, Map<String, dynamic>> summary = {};
                      for (var booth in booths) {
                        if (!summary.containsKey(booth.size)) {
                          summary[booth.size] = {
                            'count': 0,
                            'available': 0,
                            'booked': 0,
                            'price': booth.price,
                          };
                        }
                        summary[booth.size]!['count'] += 1;
                        if (booth.status == 'available') summary[booth.size]!['available'] += 1;
                        if (booth.status == 'booked') summary[booth.size]!['booked'] += 1;
                      }

                      return Table(
                        border: TableBorder.all(color: Colors.grey.shade300),
                        columnWidths: const {
                          0: FlexColumnWidth(1.5),
                          1: FlexColumnWidth(1.5),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        children: [
                          const TableRow(decoration: BoxDecoration(color: Color(0xFFEEEEEE)), children: [
                            Padding(padding: EdgeInsets.all(8), child: Text("Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text("Avail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          ]),
                          ...summary.entries.map((entry) {
                            final size = entry.key;
                            final data = entry.value;
                            return TableRow(children: [
                              Padding(padding: const EdgeInsets.all(8), child: Text(size, style: const TextStyle(fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(8), child: Text("RM ${data['price']}", style: const TextStyle(fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(8), child: Text("${data['count']}", style: const TextStyle(fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(8), child: Text("${data['available']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))),
                            ]);
                          }),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ],
        ),
      ),
    );
  }

  // Dialog to Create New Event
  void _showCreateEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    DateTimeRange? selectedDateRange;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Exhibition"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Event Name")),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  selectedDateRange = picked;
                }
              },
              child: const Text("Select Dates"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && selectedDateRange != null) {
                await _dbService.createEvent(
                  name: nameController.text,
                  location: locationController.text,
                  startDate: selectedDateRange!.start,
                  endDate: selectedDateRange!.end,
                  floorPlanUrl: '',
                  organizerId: FirebaseAuth.instance.currentUser?.uid ?? 'admin',
                );
                if (context.mounted) Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  // Dialog to edit Exhibition Name and Status
  void _showEditEventDialog(BuildContext context, String id, Map data) {
    final nameController = TextEditingController(text: data['name']);
    bool publishedStatus = data['isPublished'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Exhibition"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Exhibition Name"),
              ),
              SwitchListTile(
                title: const Text("Published"),
                value: publishedStatus,
                onChanged: (val) => setDialogState(() => publishedStatus = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await _dbService.updateEvent(id, {
                  'name': nameController.text,
                  'isPublished': publishedStatus,
                });
                if (context.mounted) Navigator.pop(context);
                _refresh(); // UI update
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // Confirmation before permanent deletion
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Exhibition?"),
        content: const Text("This will permanently remove this event record."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _dbService.deleteEvent(id);
              if (context.mounted) Navigator.pop(context);
              _refresh(); // UI update
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}