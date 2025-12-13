import 'package:flutter/material.dart';
import '../../../models/types.dart'; // Ensure this points to your types file

class BoothCard extends StatelessWidget {
  final Booth booth;
  final bool isSelected;
  final Function(Booth) onTap;

  const BoothCard({
    super.key,
    required this.booth,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.grey[200]!;
    Color textColor = Colors.black;

    if (isSelected) {
      bgColor = Colors.blue;
      textColor = Colors.white;
    } else if (booth.status == 'booked') {
      bgColor = Colors.red[400]!;
      textColor = Colors.white;
    } else if (booth.status == 'reserved') {
      bgColor = Colors.amber[300]!;
    } else if (booth.status == 'available') {
      bgColor = Colors.green[400]!;
    }

    final isClickable = booth.status == 'available';

    return GestureDetector(
      onTap: isClickable ? () => onTap(booth) : null,
      child: Opacity(
        // FIXED: Using withValues instead of deprecated withOpacity
        opacity: !isClickable ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.0),
            border: isSelected ? Border.all(color: Colors.blue.shade900, width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                booth.id, 
                style: TextStyle(
                  color: textColor, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 13.0
                )
              ),
              Text(
                'RM${booth.price.toInt()}', 
                style: TextStyle(
                  color: textColor, 
                  fontSize: 10.0
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}