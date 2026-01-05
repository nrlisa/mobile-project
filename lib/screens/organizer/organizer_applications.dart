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
        stream: dbService.getOrganizerApplications(),
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
              String displayStatus = status == 'Pending' ? 'Pending Review' : status;

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
                          _buildStatusChip(displayStatus),
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
                              onPressed: () => _showActionDialog(context, docId, 'Rejected', dbService),
                              child: const Text("Reject", style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => dbService.reviewApplication(docId, 'Approved'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, 
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Approve"),
                            ),
                          ] else if (status == 'Approved') ...[
                            TextButton(
                              onPressed: () => _showActionDialog(context, docId, 'Cancelled', dbService),
                              child: const Text("Cancel Booking", style: TextStyle(color: Colors.red)),
                            ),
                          ] else ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Status: $displayStatus", style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                                if (data['rejectionReason'] != null)
                                  Text("Reason: ${data['rejectionReason']}", style: const TextStyle(color: Colors.red, fontSize: 12)),
                              ],
                            ),
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

  void _showActionDialog(BuildContext context, String appId, String action, DbService dbService) {
    final List<String> reasons = action == 'Rejected'
        ? ['Incomplete Application', 'Booth Unavailable', 'Competitor Conflict', 'Payment Issue', 'Other']
        : ['Organizer Decision', 'Event Cancelled', 'Policy Violation', 'Other'];

    String? selectedReason;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("$action Application"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: "Reason (Required)"),
                  initialValue: selectedReason,
                  items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) {
                    setState(() => selectedReason = val);
                  },
                ),
                if (selectedReason == 'Other') ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(labelText: "Please specify reason"),
                    maxLines: 2,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () {
                  String? finalReason;
                  if (selectedReason == 'Other') {
                    finalReason = reasonController.text.trim();
                  } else {
                    finalReason = selectedReason;
                  }

                  if (finalReason == null || finalReason.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please provide a reason.")));
                     return;
                  }
                  dbService.reviewApplication(appId, action, reason: finalReason);
                  Navigator.pop(context);
                },
                child: Text("Confirm $action"),
              ),
            ],
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
      case 'pending review': color = Colors.orange; break;
      case 'cancelled': color = Colors.grey; break;
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