import 'package:flutter/material.dart';
import '../../services/db_service.dart';
import '../../models/booth.dart'; // Ensure this import points to your Booth model

class ManageBoothsScreen extends StatelessWidget {
  final String eventId;
  const ManageBoothsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final DbService dbService = DbService();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Booth Layout")),
      body: Column(
        children: [
          // 1. Legend to explain colors
          _buildLegend(),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Tap a booth to toggle Available/Reserved.\n(Booked booths cannot be changed here)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),

          // 2. Real-time Grid
          Expanded(
            child: StreamBuilder<List<Booth>>(
              // Use the new stream method from DbService
              stream: dbService.getBoothsStream(eventId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final booths = snapshot.data!;
                if (booths.isEmpty) {
                  return const Center(child: Text("No booths generated yet."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Adjust columns as needed
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.0, // Square tiles
                  ),
                  itemCount: booths.length,
                  itemBuilder: (context, index) {
                    final booth = booths[index];
                    return _buildOrganizerBoothTile(context, dbService, booth);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build each booth tile
  Widget _buildOrganizerBoothTile(BuildContext context, DbService db, Booth booth) {
    Color color;
    Color textColor = Colors.black87;
booth.status.toLowerCase();
    // Set colors based on status
    if (booth.status == 'available') {
      color = Colors.green.shade100;
    } else if (booth.status == 'booked') {
      color = Colors.red.shade100;
      textColor = Colors.red.shade900;
    } else {
      // Reserved or Maintenance
      color = Colors.grey.shade300;
      textColor = Colors.grey.shade700;
    }

    return GestureDetector(
      onTap: () {
        // Interaction Logic:
        // 1. If Booked, show warning (cannot manually un-book paid spots here)
        // 2. If Available, toggle to Reserved
        // 3. If Reserved, toggle to Available
        if (booth.status == 'booked') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cannot edit a booked booth directly."))
          );
          return;
        }

        String newStatus = (booth.status == 'available') ? 'reserved' : 'available';
        db.updateBoothStatus(eventId, booth.id, newStatus);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              booth.boothNumber, 
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)
            ),
            const SizedBox(height: 4),
            Text(
              booth.size, 
              style: TextStyle(fontSize: 10, color: textColor)
            ),
            Text(
              booth.status.toUpperCase(), 
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: textColor)
            ),
          ],
        ),
      ),
    );
  }

  // Legend widget at the top
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem(Colors.green.shade100, "Available"),
          _legendItem(Colors.red.shade100, "Booked"),
          _legendItem(Colors.grey.shade300, "Reserved"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}