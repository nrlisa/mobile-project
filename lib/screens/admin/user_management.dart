import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1)},
              children: const [
                TableRow(
                  decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text("Role", style: TextStyle(fontWeight: FontWeight.bold))),
                  ]
                ),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8), child: Text("Ayaan")),
                  Padding(padding: EdgeInsets.all(8), child: Text("ali12@gmail.com")),
                  Padding(padding: EdgeInsets.all(8), child: Text("Exhibitor")),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8), child: Text("Ahmed")),
                  Padding(padding: EdgeInsets.all(8), child: Text("min@gmail.com")),
                  Padding(padding: EdgeInsets.all(8), child: Text("Admin")),
                ]),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text("Add")),
                ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text("Edit")),
                ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Delete")),
              ],
            )
          ],
        ),
      ),
    );
  }
}