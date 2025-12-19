import 'package:flutter/material.dart';
import '../../services/db_service.dart';
import '../../services/auth_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId; 
  final String eventName;

  const EventDetailsScreen({super.key, required this.eventId, required this.eventName});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final DbService _dbService = DbService();
  late Future<List<Map<String, dynamic>>> _boothsFuture;

  @override
  void initState() {
    super.initState();
    _refreshBooths();
  }

  void _refreshBooths() {
    setState(() {
      // Parse the ID string back to an integer for SQLite
      _boothsFuture = _dbService.getBooths(int.parse(widget.eventId));
    });
  }

  void _bookBooth(Map<String, dynamic> booth) async {
    String boothNumber = booth['boothNumber'];
    int price = booth['price'];
    
    // 1. Show Confirmation Dialog
    bool? confirm = await showDialog(
      context: context, 
      builder: (c) => AlertDialog(
        title: Text("Book Booth $boothNumber?"),
        content: Text("Price: RM$price\n\nConfirm booking?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text("Confirm")),
        ],
      )
    );

    // 2. If User clicked "Confirm"
    if (confirm == true) {
      int? userId = await AuthService().getCurrentUserId();
      if (userId != null) {
        // Book it in the database
        await _dbService.bookBooth(booth['id'], userId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booth Booked Successfully!"))
          );
          // Refresh the grid so the box turns RED
          _refreshBooths(); 
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventName)),
      body: Column(
        children: [
          // Header / Legend
          Container(
            height: 100,
            width: double.infinity,
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.map, size: 30, color: Colors.grey),
                  Text("Venue Map Reference"),
                  SizedBox(height: 5),
                  Text("Green = Available  |  Red = Sold", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Select a Booth:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          // The Grid of Booths
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _boothsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var booths = snapshot.data!;
                if (booths.isEmpty) {
                  return const Center(child: Text("No booths generated for this event."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 columns
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: booths.length,
                  itemBuilder: (context, index) {
                    var booth = booths[index];
                    bool isBooked = booth['status'] == 'booked';

                    return GestureDetector(
                      onTap: isBooked ? null : () => _bookBooth(booth),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isBooked ? Colors.red[100] : Colors.green[100],
                          border: Border.all(
                            color: isBooked ? Colors.red : Colors.green,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              booth['boothNumber'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isBooked ? Colors.red : Colors.green[800],
                              ),
                            ),
                            Text(
                              isBooked ? "SOLD" : "RM${booth['price']}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}