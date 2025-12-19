import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // REQUIRED for navigation
import '../../models/types.dart';
import 'booth_selection_map.dart'; 
import '../../components/app_drawer.dart'; 

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
      // This puts the drawer on the RIGHT side
      endDrawer: const AppDrawer(role: 'Exhibitor'), 
      
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          // Validation: Booth must be selected in Step 1
          if (_currentStep == 1 && _selectedBooth == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a booth to continue.')),
            );
            return;
          }

          if (_currentStep < 2) {
            // Move to next step (0 -> 1 -> 2)
            setState(() => _currentStep += 1);
          } else {
            // --- CRITICAL FIX ---
            // This actually opens the Payment Screen
            context.push('/exhibitor/payment'); 
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
              child: const Text('Form Details (Enter Info Here)'),
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Booth'),
            content: SizedBox(
              height: 400,
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
                  const Icon(Icons.payment, size: 50, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text('Review Selection & Pay'),
                  if (_selectedBooth != null)
                    Text(
                      'Booth: ${_selectedBooth!.id}\nTotal: RM${_selectedBooth!.price.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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