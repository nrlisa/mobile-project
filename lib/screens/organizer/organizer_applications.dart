import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/db_service.dart';

class OrganizerApplicationsScreen extends StatelessWidget {
  const OrganizerApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DbService dbService = DbService();

    return Scaffold(
      appBar: AppBar(title: const Text("Review Applications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: dbService.getAllApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No applications found."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              String status = data['status'] ?? 'Pending';
              if (status == 'Paid') status = 'Pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(data['companyName'] ?? 'Unknown Company', 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          _buildStatusChip(status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.event, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(child: Text(data['eventName'] ?? 'N/A', style: const TextStyle(color: Colors.black87))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.storefront, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("Booth: ${data['boothNumber'] ?? data['boothId'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total: RM ${data['totalAmount']?.toStringAsFixed(2) ?? '0.00'}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status == 'Pending') ...[
                            TextButton(
                              onPressed: () => dbService.updateApplication(docId, {'status': 'Rejected'}),
                              child: const Text("Reject", style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => dbService.updateApplication(docId, {'status': 'Approved'}),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, 
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Approve"),
                            ),
                          ] else ...[
                            Text("Action taken: $status", style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                          ]
                        ],
                      )
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

  Widget _buildStatusChip(String status) {
    Color color;
    if (status == 'Paid') status = 'Pending';
    switch (status.toLowerCase()) {
      case 'approved': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      case 'pending': color = Colors.orange; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}