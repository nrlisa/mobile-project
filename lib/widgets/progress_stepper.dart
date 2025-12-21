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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(labels.length, (index) {
          bool isCompleted = index < currentStep;
          bool isCurrent = index == currentStep;
          Color color = (isCompleted || isCurrent) ? Colors.blue : Colors.grey[300]!;

          return Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // 1. Centered Connector Line
                if (index < labels.length - 1)
                  Positioned(
                    top: 15, // Centers the line vertically in the 30-radius circle
                    left: MediaQuery.of(context).size.width / (labels.length * 2), 
                    right: -MediaQuery.of(context).size.width / (labels.length * 2),
                    child: Container(
                      height: 2,
                      color: isCompleted ? Colors.blue : Colors.grey[300],
                    ),
                  ),

                // 2. Numbered Circle and Label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: color,
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? Colors.blue : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}