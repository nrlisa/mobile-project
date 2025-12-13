import 'package:flutter/material.dart';
import '../../models/types.dart';
import 'booth_selection_map.dart'; // Import the new map widget

class ExhibitorFlowScreen extends StatefulWidget {
  const ExhibitorFlowScreen({super.key});

  @override
  State<ExhibitorFlowScreen> createState() => _ExhibitorFlowScreenState();
}

class _ExhibitorFlowScreenState extends State<ExhibitorFlowScreen> {
  int _currentStep = 0;
  Booth? _selectedBooth;

  // Mock booth data
  final List<Booth> _mockBooths = [
    for (int i = 1; i <= 12; i++)
      Booth(
        id: 'A-${i.toString().padLeft(2, '0')}',
        hall: 'A',
        type: 'Small',
        status: i % 5 == 0 ? 'booked' : (i % 7 == 0 ? 'reserved' : 'available'),
        price: 1000.0,
      ),
    for (int i = 1; i <= 8; i++)
      Booth(
        id: 'B-${i.toString().padLeft(2, '0')}',
        hall: 'B',
        type: 'Medium',
        status: 'available',
        price: 2500.0,
        dimensions: "5m x 5m",
      ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Flow'),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 1 && _selectedBooth == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a booth to continue.')),
            );
            return;
          }
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            // Handle final step (Payment)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Proceeding to Payment...')),
            );
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          Step(
            title: const Text('Details'),
            content: Container(
              height: 200,
              alignment: Alignment.center,
              child: const Text('Form Details Placeholder'),
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Booth'),
            // Replaced placeholder with the new map widget
            content: SizedBox(
              height: 500, // Fixed height for the map container
              child: BoothSelectionMap(
                booths: _mockBooths,
                onBoothSelected: (booth) {
                  setState(() {
                    _selectedBooth = booth;
                  });
                },
              ),
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Payment'),
            content: Container(
              height: 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Payment Confirmation Placeholder'),
                  if (_selectedBooth != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Selected Booth: ${_selectedBooth!.id} - RM${_selectedBooth!.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}