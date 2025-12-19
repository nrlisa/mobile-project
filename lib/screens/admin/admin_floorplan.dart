import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class AdminFloorplanScreen extends StatelessWidget {
  const AdminFloorplanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Floorplan Upload")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Drop Zone Mockup
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 50, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text("Drop image here or Browse", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: () {}, child: const Text("Browse")),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Booth List
            Expanded(
              child: ListView(
                children: const [
                  ListTile(leading: Icon(Icons.store), title: Text("Booth A")),
                  Divider(),
                  ListTile(leading: Icon(Icons.store), title: Text("Booth B")),
                  Divider(),
                  ListTile(leading: Icon(Icons.store), title: Text("Booth C")),
                ],
              ),
            ),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Floorplan Saved!")));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                child: const Text("Save Floorplan"),
              ),
            )
          ],
        ),
      ),
    );
  }
}