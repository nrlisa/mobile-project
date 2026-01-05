import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/db_service.dart';

class UserManagementScreen extends StatelessWidget {
  UserManagementScreen({super.key});

  final DbService _dbService = DbService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final users = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  // FIXED: Move verticalAlignment here to apply to all rows
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FlexColumnWidth(1.2), // Name
                    1: FlexColumnWidth(1.5), // Email
                    2: FlexColumnWidth(0.8), // Role
                    3: FlexColumnWidth(1.2), // Category
                    4: FixedColumnWidth(85), // Actions
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                      children: [
                        Padding(padding: EdgeInsets.all(6), child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        Padding(padding: EdgeInsets.all(6), child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        Padding(padding: EdgeInsets.all(6), child: Text("Role", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        Padding(padding: EdgeInsets.all(6), child: Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        Padding(padding: EdgeInsets.all(6), child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      ]
                    ),
                    ...users.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String userId = doc.id;

                      // FIXED: Removed 'verticalAlignment' from TableRow
                      return TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(6), child: Text(data['name'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(6), child: Text(data['email'] ?? 'N/A', style: const TextStyle(fontSize: 11))),
                          Padding(padding: const EdgeInsets.all(6), child: Text(data['role'] ?? 'guest', style: const TextStyle(fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(6), child: Text(data['companyCategory'] ?? '-', style: const TextStyle(fontSize: 12))),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () => _showEditUserDialog(context, userId, data),
                                  child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () => _confirmDelete(context, userId),
                                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ... (Keep existing _showEditUserDialog and _confirmDelete methods)
  void _showEditUserDialog(BuildContext context, String id, Map data) {
    String selectedRole = data['role'] ?? 'guest';
    final categoryController = TextEditingController(text: data['companyCategory'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Role for ${data['name']}"),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedRole,
                  isExpanded: true,
                  items: ['admin', 'organizer', 'exhibitor', 'guest']
                      .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedRole = val!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: "Company Category"),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _dbService.updateUser(id, {
                'role': selectedRole,
                'companyCategory': categoryController.text,
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to remove this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _dbService.deleteUser(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}