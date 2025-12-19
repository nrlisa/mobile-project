import 'package:flutter/material.dart';

class GlobalExhibitionsScreen extends StatelessWidget {
  const GlobalExhibitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Global Exhibitions")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
             Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1.5)},
              children: const [
                TableRow(
                  decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text("Name / Loc", style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                  ]
                ),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8), child: Text("Expo01")),
                  Padding(padding: EdgeInsets.all(8), child: Text("Tech Expo 2026\n(KLCC)")),
                  Padding(padding: EdgeInsets.all(8), child: Text("12.5.2026\n-\n14.5.2026")),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8), child: Text("Expo02")),
                  Padding(padding: EdgeInsets.all(8), child: Text("Fun Fiesta 2026\n(TRX)")),
                  Padding(padding: EdgeInsets.all(8), child: Text("22.9.2026\n-\n25.9.2026")),
                ]),
              ],
            ),
             const SizedBox(height: 20),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton.icon(
                 onPressed: () {},
                 icon: const Icon(Icons.add),
                 label: const Text("Add New Global Exhibition"),
               ),
             )
          ],
        ),
      ),
    );
  }
}