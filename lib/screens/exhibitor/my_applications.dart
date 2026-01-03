import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/db_service.dart';

class MyApplications extends StatefulWidget {
  final Function(Map<String, dynamic>) onView;

  const MyApplications({super.key, required this.onView});

  @override
  State<MyApplications> createState() => _MyApplicationsState();
}

class _MyApplicationsState extends State<MyApplications> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Please login"));

    final DbService dbService = DbService();

    return Scaffold(
      appBar: AppBar(title: const Text("My Applications")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search applications...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: dbService.getExhibitorApplications(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No applications submitted yet."));
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final eventName = (data['eventName'] ?? '').toString().toLowerCase();
                  final boothNumber = (data['boothNumber'] ?? '').toString().toLowerCase();
                  final status = (data['status'] ?? '').toString().toLowerCase();
                  return eventName.contains(_searchQuery) ||
                      boothNumber.contains(_searchQuery) ||
                      status.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No matching applications found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    String status = data['status'] ?? 'Pending';
                    if (status == 'Paid') status = 'Pending';
                    final docId = doc.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    data['eventName'] ?? 'Unknown Event',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                _buildStatusChip(status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(data['eventDate'] ?? 'Date TBD', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.storefront, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("Booth: ${data['boothNumber'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Total: RM ${data['totalAmount']?.toStringAsFixed(2) ?? '0.00'}",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            if (status == 'Pending') ...[
                              const Divider(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _cancelApplication(context, dbService, docId),
                                  icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                                  label: const Text("Cancel Request", style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
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

  void _cancelApplication(BuildContext context, DbService dbService, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Application"),
        content: const Text("Are you sure you want to cancel this application? The booth will be released."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await dbService.cancelApplication(docId);
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      case 'paid': color = Colors.blue; break;
      default: color = Colors.orange;
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