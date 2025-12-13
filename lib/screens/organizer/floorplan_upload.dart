import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FloorplanUploadScreen extends StatefulWidget {
  const FloorplanUploadScreen({super.key});

  @override
  State<FloorplanUploadScreen> createState() => _FloorplanUploadScreenState();
}

class _FloorplanUploadScreenState extends State<FloorplanUploadScreen> {
  // Mock list of booths that have been identified on the map (like Page 20)
  final List<String> _identifiedBooths = ['Booth A', 'Booth B', 'Booth C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Floorplan upload", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. THE UPLOAD BOX (Dotted Style)
            GestureDetector(
              onTap: () {
                // In real app: Open File Picker
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Open File Picker...")));
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 2, style: BorderStyle.solid), 
                  // Note: Flutter needs a package for true 'dotted' borders, 
                  // but a light blue solid border looks very close to standard upload UIs.
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue.shade400),
                    const SizedBox(height: 12),
                    const Text("Browse", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("Drop image here", style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. LIST OF MAPPED BOOTHS (Matches Page 20 list)
            const Text("Detected Booths:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            
            Expanded(
              child: ListView.separated(
                itemCount: _identifiedBooths.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.store, color: Colors.blue),
                    ),
                    title: Text(_identifiedBooths[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  );
                },
              ),
            ),

            // 3. SAVE BUTTON
            ElevatedButton(
              onPressed: () {
                // Save logic
                context.pop(); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Save floorplan", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}