import 'package:flutter/material.dart';
import '../../models/types.dart'; // Ensure this path is correct for your project

// CLASS NAME MUST BE 'MyApplications'
class MyApplications extends StatelessWidget {
  final List<ApplicationRecord> applications;
  final Function(ApplicationRecord) onView;

  const MyApplications({
    super.key,
    required this.applications,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Applications")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final app = applications[index];
          return Card(
            child: ListTile(
              title: Text(app.eventName),
              subtitle: Text("Status: ${app.status}"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => onView(app),
            ),
          );
        },
      ),
    );
  }
}