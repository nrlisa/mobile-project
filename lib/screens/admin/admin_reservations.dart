import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/db_service.dart';

class AdminReservationsScreen extends StatelessWidget {
  AdminReservationsScreen({super.key});

  final DbService _dbService = DbService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Reservations")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.getAllApplications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No reservations found."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final appId = docs[index].id;
              String status = data['status'] ?? 'Pending';
              if (status == 'Paid') status = 'Pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: status == 'Pending' ? Colors.orange[50] : null,
                child: ExpansionTile(
                  title: Text("${data['companyName']} - Booth ${data['boothNumber']}"),
                  subtitle: Text("Event: ${data['eventName']} • Status: $status"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Exhibitor: ${data['companyName']}"),
                          Text("Profile: ${data['exhibitProfile']}"),
                          Text("Total Amount: RM ${data['totalAmount']?.toStringAsFixed(2) ?? '0.00'}"),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (status != 'Rejected' && status != 'Cancelled')
                                TextButton(
                                  onPressed: () => _showRejectDialog(context, appId),
                                  child: const Text("Reject/Cancel", style: TextStyle(color: Colors.red)),
                                ),
                              if (status == 'Pending')
                                ElevatedButton(
                                  onPressed: () => _dbService.reviewApplication(appId, 'Approved'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                  child: const Text("Approve"),
                                ),
                              if (status == 'Approved')
                                const Chip(label: Text("Approved"), backgroundColor: Colors.greenAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String appId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject/Cancel Application"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: "Reason for rejection/cancellation"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _dbService.reviewApplication(appId, 'Rejected', reason: reasonController.text);
              Navigator.pop(context);
            },
            child: const Text("Confirm Reject"),
          ),
        ],
      ),
    );
  }
}