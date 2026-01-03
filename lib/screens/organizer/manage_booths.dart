import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../models/event_model.dart';
import '../../models/booth.dart';

class ManageBoothsScreen extends StatefulWidget {
  final String eventId; // Optional, if filtering by specific event

  const ManageBoothsScreen({super.key, this.eventId = ''});

  @override
  State<ManageBoothsScreen> createState() => _ManageBoothsScreenState();
}

class _ManageBoothsScreenState extends State<ManageBoothsScreen> {
  final AuthService _authService = AuthService();
  final DbService _dbService = DbService();
  List<String> _organizerIds = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizerId();
  }

  Future<void> _loadOrganizerId() async {
    String? specificId = await _authService.getCurrentSpecificId();
    String? uid = _authService.currentUser?.uid;
    
    Set<String> ids = {};
    if (specificId != null) ids.add(specificId);
    if (uid != null) ids.add(uid);

    debugPrint("DEBUG: Querying events for IDs: $ids");
    if (mounted) {
      setState(() {
        _organizerIds = ids.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booth Inventory Summary"),
        centerTitle: true,
        actions: [
          // Display ID to verify against Database
          Center(child: Text(_organizerIds.isNotEmpty ? _organizerIds.first : "...", style: const TextStyle(color: Colors.black, fontSize: 10))),
          const SizedBox(width: 16),
        ],
      ),
      body: _organizerIds.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<EventModel>>(
              stream: _dbService.getOrganizerEventsMultiple(_organizerIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                
                final allEvents = snapshot.data ?? [];
                if (allEvents.isEmpty) {
                  return const Center(child: Text("No events found."));
                }

                // Filter if eventId is passed
                final events = widget.eventId.isNotEmpty
                    ? allEvents.where((e) => e.id == widget.eventId).toList()
                    : allEvents;

                if (events.isEmpty) {
                   return const Center(child: Text("Event not found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(event.location),
                        children: [_buildBoothSummaryTable(event.id)],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildBoothSummaryTable(String eventId) {
    return StreamBuilder<List<Booth>>(
      stream: _dbService.getBoothsStream(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator());
        }

        final booths = snapshot.data ?? [];
        debugPrint("DEBUG: Event $eventId has ${booths.length} booths");
        if (booths.isEmpty) {
          return const Padding(padding: EdgeInsets.all(16), child: Text("No booths generated yet."));
        }
        
        // AGGREGATE DATA: Group by Size
        final Map<String, Map<String, dynamic>> summary = {};

        for (var booth in booths) {
          if (!summary.containsKey(booth.size)) {
            summary[booth.size] = {
              'count': 0,
              'available': 0,
              'booked': 0,
              'price': booth.price,
              'booth_list': <String>[],
            };
          }
          summary[booth.size]!['count'] += 1;
          if (booth.status == 'available') {
            summary[booth.size]!['available'] += 1;
            (summary[booth.size]!['booth_list'] as List<String>).add(booth.boothNumber);
          }
          if (booth.status == 'booked') summary[booth.size]!['booked'] += 1;
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              // Header
              const TableRow(decoration: BoxDecoration(color: Color(0xFFEEEEEE)), children: [
                Padding(padding: EdgeInsets.all(8), child: Text("Type", style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(8), child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(8), child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(8), child: Text("Available Booths", style: TextStyle(fontWeight: FontWeight.bold))),
              ]),
              // Data Rows
              ...summary.entries.map((entry) {
                final size = entry.key;
                final data = entry.value;

                return TableRow(children: [
                  Padding(padding: const EdgeInsets.all(8), child: Text(size)),
                  Padding(padding: const EdgeInsets.all(8), child: Text("RM ${data['price']}")),
                  Padding(padding: const EdgeInsets.all(8), child: Text("${data['count']}")),
                  Padding(padding: const EdgeInsets.all(8), child: Text("${data['available']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                ]);
              }),
            ],
          ),
        );
      },
    );
  }
}