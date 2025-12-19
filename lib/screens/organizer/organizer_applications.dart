import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class OrganizerApplicationsScreen extends StatelessWidget {
  const OrganizerApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Applications")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppCard(context, "Technology Corp", "Medium", "05/11/2025", "Pending"),
          _buildAppCard(context, "MindTech", "Small", "12/10/2025", "Rejected"),
          _buildAppCard(context, "VeecoTech", "Large", "01/11/2025", "Pending"),
        ],
      ),
    );
  }

  Widget _buildAppCard(BuildContext context, String company, String type, String date, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Type: $type | Date: $date", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 16),
            if (status == 'Pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () {}, child: const Text("Reject", style: TextStyle(color: Colors.red))),
                  const SizedBox(width: 10),
                  ElevatedButton(onPressed: () {}, child: const Text("Approve")),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () {}, child: const Text("View Details")),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    if (status == 'Approved') color = AppTheme.successGreen;
    if (status == 'Rejected') color = AppTheme.errorRed;
    if (status == 'Pending') color = AppTheme.warningAmber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}