// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/db_service.dart';

class MyApplications extends StatelessWidget {
  final Function(Map<String, dynamic>) onView;
  final DbService _dbService = DbService(); 

  MyApplications({
    super.key,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // Use a consistent background color as seen in previous steps
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(
        title: const Text("My Applications", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          // Ensuring safe navigation back to the dashboard
          onPressed: () => context.pop(), 
        ),
      ),
      body: user == null
          ? const Center(child: Text("Authentication required."))
          : StreamBuilder<QuerySnapshot>(
              // Listen to the user's specific applications collection
              stream: _dbService.getExhibitorApplications(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // This helps catch the Firestore Index error we saw earlier
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "Error: ${snapshot.error}", 
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      )
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No applications found.", style: TextStyle(color: Colors.grey)),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final appData = doc.data() as Map<String, dynamic>;
                    final String docId = doc.id; 
                    
                    return _buildApplicationCard(context, appData, docId);
                  },
                );
              },
            ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, Map<String, dynamic> app, String docId) {
    // Business logic: Applications must stay 'Pending' until organizer approval
    String status = app['status'] ?? 'Pending';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        title: Text(
          app['companyName'] ?? 'Unknown Company', 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text("Booth No: ${app['boothId']}", style: const TextStyle(color: Colors.black87)),
            Text(
              "Total Amount: RM ${app['totalAmount']?.toStringAsFixed(2) ?? '0.00'}", 
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
        // Trailing section for status and cancellation actions
        trailing: Wrap(
          spacing: 0, 
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildStatusBadge(status),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) {
                if (value == 'cancel') {
                  _confirmCancel(context, docId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text("Cancel Request", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => onView(app),
      ),
    );
  }

  void _confirmCancel(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cancel Application?"),
        content: const Text("This will permanently remove your booking. This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text("CLOSE"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Delete the document from Firestore via the service
              await _dbService.cancelApplication(docId); 
              
              if (context.mounted) {
                Navigator.pop(dialogContext); // Close dialog
                
                // Show confirmation snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Application successfully cancelled"),
                    backgroundColor: Colors.black87,
                  ),
                );
              }
            },
            child: const Text("CONFIRM CANCEL"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    // Standardizing 'Pending' status badge with orange theme
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Colors.orange[800],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}