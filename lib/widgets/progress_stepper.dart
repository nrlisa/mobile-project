import 'package:flutter/material.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep;
  final List<String> labels = ['Event', 'Booth', 'Form', 'Review'];

  ProgressStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(labels.length, (index) {
          bool isCompleted = index < currentStep;
          bool isCurrent = index == currentStep;
          Color color = (isCompleted || isCurrent) ? Colors.blue : Colors.grey[300]!;

          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: color,
                      child: isCompleted 
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    const SizedBox(height: 4),
                    Text(labels[index], style: TextStyle(fontSize: 10, color: isCurrent ? Colors.blue : Colors.grey)),
                  ],
                ),
                if (index < labels.length - 1)
                  Expanded(child: Container(height: 2, color: isCompleted ? Colors.blue : Colors.grey[300])),
              ],
            ),
          );
        }),
      ),
    );
  }
}