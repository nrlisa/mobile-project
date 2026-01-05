import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/db_service.dart';

class MyApplications extends StatelessWidget {
  final Function(Map<String, dynamic>) onView;

  const MyApplications({super.key, required this.onView});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final DbService dbService = DbService();

    if (user == null) return const Center(child: Text("Please log in."));

    return Scaffold(
      appBar: AppBar(title: const Text("My Applications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: dbService.getExhibitorApplications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No applications found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              String status = data['status'] ?? 'Pending';
              if (status == 'Paid') status = 'Pending';
              final eventId = data['eventId'];
              final eventName = data['eventName'] ?? 'Unknown Event';
              final boothNumber = data['boothNumber'] ?? 'Unknown';
              final rejectionReason = data['rejectionReason'];

              Color statusColor = Colors.grey;
              if (status == 'Approved') statusColor = Colors.green;
              if (status == 'Rejected' || status == 'Cancelled') statusColor = Colors.red;
              if (status == 'Pending') statusColor = Colors.orange;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(eventName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          Row(
                            children: [
                              Chip(
                                label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                backgroundColor: statusColor,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                              if (status == 'Pending')
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: "Edit Application",
                                  onPressed: () => _showEditDialog(context, docId, data, dbService),
                                ),
                              if (status == 'Pending' || status == 'Approved')
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: "Cancel Booking",
                                  onPressed: () => _confirmDelete(context, docId, dbService),
                                ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Booth: $boothNumber"),
                      
                      // Show Rejection Reason if available
                      if (rejectionReason != null && (status == 'Rejected' || status == 'Cancelled'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Reason: $rejectionReason", style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
                        ),
                        
                      const SizedBox(height: 16),
                      
                      // Re-apply Button for Rejected/Cancelled applications
                      if (status == 'Rejected' || status == 'Cancelled')
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (eventId != null) {
                                // Restart from Step 1 (Booth Selection) for this event
                                context.go('/exhibitor/flow', extra: {'eventId': eventId});
                              }
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text("Re-apply"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, 
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
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

  void _showEditDialog(BuildContext context, String docId, Map<String, dynamic> data, DbService dbService) {
    final descriptionController = TextEditingController(text: data['companyDescription'] ?? '');
    final profileController = TextEditingController(text: data['exhibitProfile'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Application"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Company Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: profileController,
                decoration: const InputDecoration(labelText: "Exhibit Profile"),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              dbService.updateApplication(docId, {
                'companyDescription': descriptionController.text,
                'exhibitProfile': profileController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Application updated.")));
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId, DbService dbService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Application"),
        content: const Text("Are you sure you want to cancel this application? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Back"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await dbService.cancelApplication(docId);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Application cancelled successfully.")));
                }
              } catch (e) {
                // Handle error
              }
            },
            child: const Text("Confirm Cancel"),
          ),
        ],
      ),
    );
  }
}