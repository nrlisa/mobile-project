import 'package:flutter/material.dart';
import '../../services/db_service.dart';

class ManageBoothsScreen extends StatelessWidget {
  final String eventId;
  const ManageBoothsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final DbService dbService = DbService();

    return Scaffold(
      appBar: AppBar(title: const Text("Booth Layout (Grid)")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Select a booth to edit availability (Ref: Static Map)"),
          ),
          Expanded(
            child: StreamBuilder(
              stream: dbService.getBoothsForEvent(eventId),
              builder: (context, snapshot) {
                // Generate a 10x10 Grid representing booth locations [Inference]
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: 25, // Fixed slots for simplicity
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text("Booth\n${index + 1}", 
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10)
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
}